module('cache', package.seeall)

require 'app'
require 'misc'
require 'query'
require 'playlist_helpers'
require 'compare_playlists'

local cacheFile = F(LYRICS_DIR, 'cache')
local lyricsCache = {}
local fileTypes = {'html', 'txt'}

LEVENSHTEIN_ARTIST_TRESHOLD = 0.5
LEVENSHTEIN_TITLE_TRESHOLD = 0.8

local function createLyricsDirs()
  -- check if lyrics dir exists and make it if not
  os.createDir(LYRICS_DIR)
  for i, searchSite in ipairs(search_sites) do
    os.createDir(F(LYRICS_DIR, searchSite.site))
  end
end

function getNrItems()
  local nrItems = 0
  for artist, titleTable in pairs(lyricsCache) do
    for title, siteTable in pairs(titleTable) do
      for site, cachedItem in pairs(siteTable) do
        nrItems = nrItems + 1
      end
    end
  end
  return nrItems
end

local function loadCache()
  local cacheLoaded = false
  if os.exists(cacheFile) then
    print('Loading cache file...' .. cacheFile)
    if not pcall(function()
      lyricsCache = table.loadFromFile(cacheFile) or {}
      cacheLoaded = true
    end) then
      print('Cache corrupt, creating new one...')
    end
  end
  if not cacheLoaded or not lyricsCache then
    buildCache()
  end
end

function buildCache(updateCallback)
  print('Rebuilding cache...')
  lyricsCache = {}
  -- Search for newly added files
  for i, searchSite in ipairs(search_sites) do
    local site = searchSite.site
    for file in lfs.dir(F(LYRICS_DIR, site)) do
      local artist, title, ext = file:match(playlist_helpers.artist_title_ext)
      if site and artist and title and (ext == 'txt' or ext == 'html') then
        file = F(LYRICS_DIR, site, file)
        addToCache({artist=artist, title=title}, searchSite, file)
      end
    end
  end
  -- Search for removed files
  for artist, titleTable in pairs(lyricsCache) do
    for title, siteTable in pairs(titleTable) do
      for site, cachedItem in pairs(siteTable) do
        local somethingExisted = false
        local removedItem
        for i, ext in ipairs(fileTypes) do
          if cachedItem[ext] then
            if os.exists(cachedItem[ext]) then
              somethingExisted = true
            else
              removedFile = cachedItem[ext]
              print('Remove from cache: ', cachedItem[ext])
              cachedItem[ext] = nil
            end
          end
        end
        if not somethingExisted then
          print('Removing cached item', artist, title, site)
          removedItem = string.format('Artist: %s, Title: %s, Site: %s', artist, title, site)
          lyricsCache[artist][title][site] = nil
        end
        if updateCallback then updateCallback(removedItem) end
      end
      -- Check if siteTable became empty because of removal of cached items
      removeEmptyOccurrences(artist, title)
    end
  end
end

function removeUnusedLyrics(updateCallback)
  for artist, titleTable in pairs(lyricsCache) do
    for title, siteTable in pairs(titleTable) do
      local sortedSites = query.sortSites(siteTable)
      -- Get site ranked highest and that is not ignored
      local selSiteIndex, selCachedItem = table.ifind(sortedSites, function(i, v) return not v.ignore and v.txt end)
      if selCachedItem then
        for siteName, cachedItem in pairs(siteTable) do
          local fileName = nil
          if siteName ~= selCachedItem.site then
            -- Physically remove txt and/or html
            for i, fileType in ipairs(fileTypes) do
              if cachedItem[fileType] and os.exists(cachedItem[fileType]) then
                fileName = cachedItem[fileType]
                print(string.format('Removing file "%s"', cachedItem[fileType]))
                os.remove(cachedItem[fileType])
              end
            end
            lyricsCache[artist][title][siteName] = nil
          end
          if updateCallback then updateCallback(fileName or '') end
        end
      end
    end
  end
end

function addToCache(track, search_site, file, content)
  local artist, title = track.artist, track.title
  assert(artist and title and search_site, "One of the parameters artist, title or search_site is nil!")
  artist = artist:lower()
  title = title:lower()
  local site = search_site.site
  local ext = os.getExtension(file)

  if content then
    file = os.format_file(ext, search_site, track)
    os.writeTo(file, content)
    if content:match(query.emptyFileMatch) then
      file = nil
    end
  end

  if not lyricsCache[artist] then lyricsCache[artist] = {} end
  if not lyricsCache[artist][title] then lyricsCache[artist][title] = {} end

  -- artist & title are inserted into the entries as well, for convenience
  -- in the scanCache(). In scanCache() namely, the artist/title combination
  -- searched for, can differ slightly from the artist/title title combinations
  -- inserted here. We're talking about differences like "The Beatles"/"Beatles"
  -- or "You'll never walk alone"/"Youll never walk alon", which can indeed
  -- be also spelling errors

  -- Check if file content is not empty
  if file then
    if not os.exists(file) or os.read(file):match(query.emptyFileMatch) then
      print(string.format('Found %s text file "%s"', os.exists(file) and 'empty' or 'unaccessible', file))
      file = nil
    end
  end
  if not lyricsCache[artist][title][site] then
    lyricsCache[artist][title][site] = {[ext] = file, artist = artist, title = title, site = site} -- site is needed for sorting sites list
  else
    lyricsCache[artist][title][site][ext] = file
  end
end

function removeEmptyOccurrences(artist, title)
  if table.isEmpty(lyricsCache[artist][title]) then
    lyricsCache[artist][title] = nil
  end
  if table.isEmpty(lyricsCache[artist]) then
    lyricsCache[artist] = nil
  end
end

function removeFromCache(info, ext)
  if info and not table.isEmpty(info) and
          lyricsCache[info.artist] and
          lyricsCache[info.artist][info.title] and
          lyricsCache[info.artist][info.title][info.site] then
    if info[ext] and os.exists(info[ext]) then
      os.remove(info[ext])
    end

    lyricsCache[info.artist][info.title][info.site][ext] = nil
    -- If html & txt do not exist, delete entire cache entry
    if not lyricsCache[info.artist][info.title][info.site].html and not lyricsCache[info.artist][info.title][info.site].txt then
      lyricsCache[info.artist][info.title][info.site] = nil
    end
    removeEmptyOccurrences(info.artist, info.title)
  end
end

-- returns either:
-- {ignore, html, txt, artist, title}, if searchSite ~= nil
-- a map of site --> {ignore, html, txt, artist, title}, otherwise
-- Only checks entire cache with levenshtein algorithm if rescan == true, otherwise return nil
function scanCache(track, searchSite, rescan)
  local artist, title = track.artist, track.title
  artist = artist:lower()
  title = title:lower()

  -- Try to index lyricsCache table directly
  if lyricsCache[artist] and lyricsCache[artist][title] and not table.isEmpty(lyricsCache[artist][title]) then
    if searchSite then
      return lyricsCache[artist][title][searchSite.site]
    else
      return lyricsCache[artist][title]
    end
  end

  if not rescan then return nil end

  for cachedArtist, titles in pairs(lyricsCache) do

    -- E.g. the difference between 'the doors' and 'doors' is 0.55555555
    -- But levenshtein('rem', 'r.e.m.') == 0.5, that's why we made it this value
    -- compare.levenshtein is 5-6 times quicker than lua implementation!!
    if compare.levenshtein(artist, cachedArtist) >= LEVENSHTEIN_ARTIST_TRESHOLD then
      for cachedTitle, sites in pairs(titles) do
        -- Compare percentage of equal chars of two strings
        -- We consider a similarity of > 80 % enough for title
        local titleEq = compare.levenshtein(title, cachedTitle)

        if titleEq > LEVENSHTEIN_TITLE_TRESHOLD and not table.isEmpty(sites) then
          -- Adapting artist & title of track to make sure next time it will be found
          -- immediately by indexing lyricsCache table
          -- Old artist & title strings are stored in customArtist & customTitle
          -- to ensure that the playlist seems unchanged
          -- (see comment "Try to index lyricsCache table directly")
          track.customArtist = track.artist
          track.customTitle = track.title
          track.artist = cachedArtist
          track.title = cachedTitle
          if searchSite then
            return sites[searchSite.site]
          else
            return sites
          end
        end
      end
    end
    coroutine.wait()
  end
end

-- Function that is called when playlist is loaded
function rescanPlaylist(tracks)
  local allTracks = playlist_api.getPlaylist()
  app.addCo(function()
    for i, track in ipairs(tracks) do
      local notFoundInCache = not IsTxtInCache(track)
      IsTxtInCache(track, true)
      if notFoundInCache ~= track.notFoundInCache then
        local index = table.find(allTracks, track)
        print('Found following song with thorough search!:', index, track.artist, track.title)
        playlist_gui.widget:updateItem(index, track)
      end
      coroutine.wait()
    end
  end, nil,
  function()
    print('Finished rescanning playlist')
  end
  )
end

function IsTxtInCache(track, rescan)
  local exists = false
  local sites = cache.scanCache(track, nil, rescan)
  for siteName, info in pairs(sites or {}) do
    if info.txt then
      exists = true
      break
    end
  end
  -- set notFoundInCache flag
  if rescan then track.notFoundInCache = not exists end
  return exists
end

function saveCache(customFile)
  table.saveToFile(customFile or cacheFile, lyricsCache)
end

function saveTxtCache(customFile)
  table.saveToFileText(customFile or cacheFile .. '.lua', lyricsCache)
end

os.calcTime('Loading cache', function()
  loadCache()
  createLyricsDirs()
end)

