module('query', package.seeall)

local search = false
GOOGLE_BAN = "CAPTCHA"
emptyFileMatch = '^[%c%s]*$'
local google_delimiter = [[<h%d class=%"r%">]]

require 'load_config'
require 'misc'
require 'load_search_sites'
require 'cache'
require 'playlist_api'      -- playlist scanning functions
require 'replace'      -- string replacements that will be made lyrics
require 'constants'    -- header & footer for latex file
require 'socketinterface'
require 'task'

os.format_file = function(ext, search_site, mp3)
  local artist, title = mp3.artist, mp3.title
  assert(artist and title and search_site, "One of the parameters artist, title or search_site is nil!")
  assert(search_site.site, 'Invalid search site')
  assert(ext, 'No extension given')
  local res = F(LYRICS_DIR, search_site.site, string.format([[%s.%s]], replace(artist .. ' - ' .. title, fileReplacements), ext))
  return res
end

--[[
local function request(url, fn)
  local taskID = task.create('socketinterface.lua', {url, fn})
  coroutine.waitFor(function() local running = task.isrunning(taskID) return not running end)
end
--]]

---[[
local function request(url, fn)
  socketinterface.request(url, fn)
end
--]]

function executeQuery(search_site, mp3, keepTempFile)
  local artist, title, customArtist, customTitle = mp3.artist, mp3.title, mp3.customArtist, mp3.customTitle

  local tmpname = os.tmpname():gsub('\\', '')
  local fn = F(LYRICS_DIR, tmpname .. '.html')

  artist = replace(customArtist or artist, repl_for_query)
  title = replace(customTitle or title, repl_for_query)
  query_str = title
  query_str = artist .. "+" .. query_str

  local onSite = search_site and (' on ' .. search_site.site) or ''
  print(string.format("Searching for %s - %s%s", artist, title, onSite))
  local content
  local siteAppendix = search_site and ('+site%3A' .. search_site.site) or ''
  request(string.format('http://www.google.com/search?q=%s%s', query_str, siteAppendix), fn)
  content = os.read(fn)
  if not keepTempFile then
    os.remove(fn)
  end
  if content and content:find(GOOGLE_BAN) then
    return content, fn, GOOGLE_BAN
  end
  if not content or content == '' or content:find('Your search .* did not match any documents') then
      return nil, fn
  else
      return content, fn
  end
end

local function restrictQuery(search_site, query)
  if not search_site.detect_query then return query end
  for _, restrict in ipairs(search_site.detect_query) do
    if type(restrict) == 'string' and query:find(restrict) then return nil end
  end
  return query
end

local function queryGoogle(search_site, mp3)
  local content, fn, err = executeQuery(search_site, mp3, config.keepTempFile)
  if err == GOOGLE_BAN then return GOOGLE_BAN end
  if content then
    begin_str, end_str = content:find(google_delimiter)

    first_result = content:match('<a href=%"/url%?q=([^"&;]*)', end_str)
    if first_result and restrictQuery(search_site, first_result) then -- we do not want lyrics sites to search
      local fn = os.format_file('html', search_site, mp3)
      request(first_result, fn)
      cache.addToCache(mp3, search_site, fn)
    end
  end
end

function getLyricFragment(content, lBegin, lEnd)
  local endLyrics
  local _, beginLyrics   = content:find(lBegin)
  if lEnd then
    endLyrics, _     = content:find(lEnd, beginLyrics)
  end
  print('****** Beginning lyrics, end lyrics: ', beginLyrics, endLyrics)
  if beginLyrics then
    return content:sub(beginLyrics+1, endLyrics and (endLyrics-1))
  end
end

-- conversions that need to be made to go from text files to either miktex format or libharu compatible text
local function doAsciiConversions(content)
  if content then
    local conversions = {}
    if config.pdfGenerator == 'Miktex' then
      conversions = {'ascii_to_latex'}
    elseif config.pdfGenerator == 'Singalong pdf' then
      conversions = {'ascii_to_libharu'}
    end
    for i, conversion in ipairs(conversions) do
      content = require('convert_' .. conversion)(content)
    end
    return content
  end
end

-- returns file that has been found (lyrics file or replace lyrics file),
-- content of this file and
-- cache entry
function getLyrics(ext, search_site, mp3, disableAsciiConversions)
  local artist, title = mp3.artist, mp3.title
  if disableAsciiConversions == nil then disableAsciiConversions = true end
  if not search_site or not artist then
    search_site, artist, title = getSelection()
  end

  if search_site and artist and title then -- can be nil in case playlist is empty
    local fileName, content, info

    local cachedItem = cache.scanCache(mp3, search_site)
    if cachedItem and cachedItem[ext] then
      fileName = cachedItem[ext]
      content = os.read(fileName)
      info = cachedItem
    end

    if ext == 'txt' and not disableAsciiConversions then
      content = doAsciiConversions(content)
    end
    return fileName, content, info
  end
end

-- This function searches for occurrences between two pipes, like this || .... ||
-- The special chars of these strings (^   $  (    )    %  .   [   ]   *   +   -   ?) won't be escaped
-- Moreover, the 'fake' newlines \\n will be converted to \n
local function formatSearch(str)
  local rest = str
  local search = ''
  while rest do
    local normal, special, r = rest:match('(.-)||(.-)||(.-)$')
    if not normal then
      normal = rest:match('(.-)$')
      search = search .. _(normal)
      rest = nil
    else
      search = search .. _(normal) .. special:gsub('\\n', '\n')
      rest = r
    end
  end
  return search
end

local function formatBeginHtmlSearch(searchSite)
  local beginQuery, endQuery = {}, ''
  for i, str in ipairs(searchSite.lyric_begin) do
    table.insert(beginQuery, formatSearch(str))
  end
  endQuery = formatSearch(searchSite.lyric_end)
  return beginQuery, endQuery
end

function extractLyrics(search_site, mp3, useRenamed)
  local fn, content, whichFile = getLyrics('html', search_site, mp3)
  if not content then
    return nil
  end

  local lyric_begin, lyric_end = formatBeginHtmlSearch(search_site)
  local sub
  local nrSearches = #lyric_begin
  for index, lBegin in pairs(lyric_begin) do
    sub = getLyricFragment(sub or content, lBegin, nrSearches == index and lyric_end)
  end
  content = sub

  if content then
    local conversions = {'html_to_ascii', 'misc', 'utf16_to_ascii'}
    for i, conversion in ipairs(conversions) do
      content = require('convert_' .. conversion)(content)
    end
    if search_site.min_length and content:len() < search_site.min_length then return nil end
    cache.addToCache(mp3, search_site, os.format_file('txt', search_site, mp3), content)
    return content
  else
    return nil
  end
end

local function findSearchSite(searchSiteName)
  return table.find(search_sites, function(i, site) return site.site == searchSiteName end)
end

function sortSites(sites)
  local sortedSites = {}
  for i, v in pairs(sites) do table.insert(sortedSites, v) end
  -- sort site list on basis of their index in search_sites
  table.sort(sortedSites, function(site1, site2) return findSearchSite(site1.site) < findSearchSite(site2.site) end)
  return sortedSites
end

function retrieveLyrics(mp3)
  local lyr
  local sites = cache.scanCache(mp3) or {}
  sites = sortSites(sites)
  local siteName, selectedSite = table.ifind(sites, function(i, v) return not v.ignore and v.txt end)
  if selectedSite then
    lyr = os.read(selectedSite.txt)
  end

  return doAsciiConversions(lyr)
end

local function waitInterval(interval)
  print('waiting ' .. interval .. ' seconds...')
  local beginTime = os.clock()
  while os.clock() - beginTime < interval do
     -- when downloadLyrics is invoked by test code we are not in coroutine
     -- so coroutine.yield() will fail
    if coroutine.running() then
      coroutine.yield()
    end
  end
end

function downloadLyrics(mp3, customSearchSites, totalWaitTime, lastMp3)
  local artist, title, customArtist, customTitle = mp3.artist, mp3.title, mp3.customArtist, mp3.customTitle

  --print(customArtist or artist, customTitle or title, ":")
  for index, search_site in pairs(customSearchSites) do
    -- pass site name for progress bar update
    if coroutine.running() then
      coroutine.yield(search_site.site)
    end
    local beginTime = os.clock()
    local info = cache.scanCache(mp3, search_site)
    if not (info and info.txt) then
      local res = queryGoogle(search_site, mp3)
      if res then
        return res
      end
    end
    local lyr = extractLyrics(search_site, mp3)

    -- determine time that we wasted with request() and rest of processing,
    -- so we can subtract this from waitInterval() below
    local subtractTime = os.clock() - beginTime

    if totalWaitTime and
      not (lastMp3 and
        ((config.stopAfterFirstHit and lyr) or
        (index == #customSearchSites))) then
          waitInterval(totalWaitTime - subtractTime)
    end

    if config.stopAfterFirstHit then
      if lyr then
        print('found: ', search_site.site, '\n\n')
        return
      end
    else
      print('\nsite ' .. index .. ': ' .. search_site.site)
      print(lyr and lyr:sub(1,200))
    end
  end
  return
end

if not APPLOADED then
  --downloadLyrics({artist='neil young', title='unknown legend'}, {search_sites[4]})

  --print(executeQuery(search_sites[4], {artist='neil young', title='unknown legend'}, true))
  --queryGoogle(search_sites[4], {artist='neil young', title='unknown legend'})

  --print(extractLyrics(search_sites[4], {artist='neil young', title='unknown legend'}))

  --print(socketinterface.request('http://www.google.com/search?q=neil+young+unknown+legend+site%3Awww.lyricsfreak.com', 'C:\Users\Wouter\AppData\Local\SinGaLonG\lyrics\s1j8..html'))

  print(request('http://www.google.com/search?q=neil+young+unknown+legend%3Awww.lyricsfreak.com', [[C:\Users\Wouter\AppData\Local\SinGaLonG\lyrics\s1j8..html]]))
end
