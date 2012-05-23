module('playlist_api', package.seeall)

require 'query'
require 'misc'
require 'spotify_playlist'

local playlistFileName

artist_title = '([^%c]-)%s+%-%s+([^%c]+)'
artist_title_ext = artist_title .. '%.([^.]+)$'

local function setPlaylistFileName(fn)
  mainDialog.title = 'SinGaLonG' .. ' - ' .. tostring(fn)
  playlistFileName = fn
end

function getNotFoundPlaylistName()
  return os.getFileWithoutExt(playlistFileName) .. '_notfound.' .. 'm3u'
end

function getLatexFileName()
  return os.getFileWithoutExt(playlistFileName) ..  '.tex'
end

function getPlaylistName()
  return playlistFileName
end

-- load mp3 table that contains ranking info of search sites
local function loadMp3Table(singFile)
  if os.exists(singFile) then
    local mp3Info = table.loadFromFile(singFile)
    --local mp3Info = dofile(singFile)
    return mp3Info
  end
end

-- save mp3 table that contains ranking info of search sites
function saveMp3Table(fn, mp3Table)
  fn = fn or playlistFileName
  mp3Table = mp3Table or mp3s
  if mp3Table and #mp3Table > 0 and fn then
    table.saveToFile(os.getFileWithoutExt(fn) .. '.sing', mp3Table)
  end
end

local function openM3U(fn)
  local mp3s = gatherMp3Info(fn)
  return mp3s
end

local function openTXT(fn)
  file = io.open(fn)
  assert(file, string.format("File %q doesn't exist!", fn))
  local content = file:read("*a")
  local mp3s = gatherFromCustomPlaylist(content)
  return mp3s
end

local function showNewPlaylistDialog()
  local filedlg = iup.filedlg{dialogtype = "SAVE", title = "Save new playlist as",
                        extfilter = "SingAlonG Playlists (*.sing)|*.sing;|"}
  filedlg:popup (iup.ANYWHERE, iup.ANYWHERE)
  if filedlg.status == '1' or filedlg.status == '0' then -- 1: new file, 0: existing
    return filedlg.value
  end
end

function makeNewPlaylist()
  local sample = [[The Beatles - Yellow Submarine
Neil Young - Old man
]]
  local playlistEntries = nil
  local multiline = iup.text{expand = 'YES', multiline = 'YES', value = sample}

  local function okFunction()
    playlistEntries = gatherFromCustomPlaylist(multiline.value)
    return iup.CLOSE
  end

  local function spotifyFunction()
    playlistEntries = spotify_playlist.parseSpotifyPlaylist(multiline.value)
    return iup.CLOSE
  end

  local playlistDlg = iup.dialog
  {
    iup.vbox
    {
      iup.label{title="Give multiple artist - title entries on each line:"},
      multiline,
      iup.hbox
      {
        iup.button
        {
          title = 'OK',
          action = okFunction,
        },
        iup.button
        {
          title = 'Import from spotify',
          action = spotifyFunction,
        },
        iup.button
        {
          title = 'Cancel',
          action = function()
            return iup.CLOSE
          end
        },
      },
      gap="5",
      margin = "5x5",
      alignment = "ACENTER",
    },
    k_any = function(widget, key, press)
      if (key == iup.K_ESC) then
        return iup.CLOSE
      elseif (key == iup.K_cCR) then
        return okFunction()
      end
    end,

    title = "Enter playlist...",
    parentdialog = mainDialog,
    menubox = "NO",
    resize = "NO",
    minsize="400x300",
    size="400x300",
  }

  local res = iup.Popup(playlistDlg, iup.ANYWHERE, iup.ANYWHERE)
  setDialogIcon(playlistDlg)

  if not playlistEntries then return end

  local playlistName = showNewPlaylistDialog()
  if not playlistName then return end
  if not os.isFileWritable(playlistName) then iup.Message('Warning', string.format('Cannot write to file "%s"! Make sure it is not write protected.', playlistName)) return end
  if not playlistName:match('%.sing$') then playlistName = playlistName .. '.sing' end

  -- Save currently loaded mp3 table
  saveMp3Table()
  -- Save new custom playlist
  saveMp3Table(playlistName, playlistEntries)
  openPlaylist(playlistName, true)
end

local function showOpenPlaylistDialog()
  local filedlg = iup.filedlg{dialogtype = "OPEN", title = "Open playlist",
                        extfilter = "All Playlist Types (*.sing; *.m3u; *.txt)|*.sing;*.m3u;*.txt|SingAlonG Playlists (*.sing)|*.sing;|Playlists (*.m3u)|*.m3u;|Text Files (*.txt)|*.txt;|"}
  filedlg:popup (iup.ANYWHERE, iup.ANYWHERE)
  if filedlg.status == '0' then
    return filedlg.value
  end
end

function openPlaylist(fn, newSingFile)
  if not fn then
    fn = showOpenPlaylistDialog()
  end
  if fn and os.exists(fn) then
    os.calcTime('open playlist', function()

      local reloadM3u = false
      local strippedFile, ext = os.getFileWithoutExt(fn)
      local singFile = strippedFile .. '.sing'
      if ext == '.m3u' and os.exists(singFile) then
        local ret = iup.Alarm('Warning', 'Do you want to discard of copy "' .. strippedFile .. '"?', 'Yes', 'No', 'Cancel')
        if ret == 1 then -- Ok
          reloadM3u = true
        elseif ret == 3 then -- Cancel
          return
        end
      elseif not os.exists(singFile) then
        reloadM3u = true
      end
      if not newSingFile then
        saveMp3Table()
      end
      if ext == '.m3u' then
        if reloadM3u then
          _G.mp3s = openM3U(fn)
        end
      elseif ext == '.txt' then
        _G.mp3s = openTXT(fn)
      elseif ext == '.sing' then -- do nothing, sing files will be opened in loadMp3Table()
      end
      if not reloadM3u then
        local newMp3s = loadMp3Table(singFile)
        if not newMp3s then
          iup.Message('Warning', string.format('Loading of sing file "%s" failed!', singFile))
          return
        end
        _G.mp3s = newMp3s
      end

      setPlaylistFileName(fn)
      activateButtons()

      updateGui('playlist', 'searchsites', 'lyrics')
      playlist_gui.resize_cb()
      playlist_gui.widget:modifySelection(1)
      cache.rescanPlaylist(mp3s)
    end)
  end
end

local function gatherInverse(root, dir, selection)
  result = {}
  for entry in lfs.dir(root .. dir) do
    if not table.ifind(selection, dir .. entry) and entry ~= "." and entry ~= ".." then
      table.insert(result, entry)
    end
  end
  return result
end

local function gatherMp3s(fn)
  file = io.open(fn)
  content = file:read("*a")
  result = {}
  for v in (string.gmatch(content, "#EXTINF[^%c]*\n([^%c]*)\n")) do
    table.insert(result, v)
  end
  return result
end

local function extractFromFile(fileStr)
  local artist, title = fileStr:match("^%(?[%d]*%)?[%.]*[%.%- ]+" .. artist_title)
  if not artist then
    artist, title = fileStr:match(artist_title)
  end
  return artist, title
end

function gatherFromCustomPlaylist(playlist)
  local tracks = {}
  for artist, title in playlist:gmatch(artist_title) do
    if artist and title then
      table.insert(tracks, {artist = artist, title = title})
    end
  end

  return tracks
end

function gatherMp3Info(fn)
  file = io.open(fn)
  assert(file, string.format("File %q doesn't exist!", fn))
  content = file:read("*a")
  tracks = {}
  for playlistEntry, track, v in (string.gmatch(content, "(#EXTINF:[%d]+,([^%c]*)\n([^%c]*)\n)")) do
    local artist, title
    artist, title = extractFromFile(track)
    if not artist or not title then
      local path, fileStr = v:match("(.-)([^:\\/]+).mp3$")

      if fileStr then
        artist, title = extractFromFile(fileStr)
        if not artist then
          artist, album = path:match([[([^\/-]-)%s+%-%s+([^\/-]*)]])
          if artist then
            title = fileStr:match("[%d]+[%.]* (.*)")
          end
        end
      end
    end
    if artist and title then
      table.insert(tracks, {artist = artist, title = title, playlistEntry = playlistEntry})
    end
  end

  return tracks
end

local function extractDirs(files)
  result = {}
  for _,file in pairs(files) do
    match = string.match(file, [[(.*\)(.*)]])
    if not table.ifind(result, match) then
      table.insert(result, match)
    end
  end
  return result
end

function deleteNotInPlayList(mp3s, root, fn)
  _G.mp3s = gatherMp3s(root .. fn)
  dirs = extractDirs(mp3s)
  for _,dir in pairs(dirs) do
    inverse = gatherInverse(root, dir, mp3s)
    print([[About to delete the following files in "]] .. root .. dir .. [["]])
    print("\t" .. table.concat(inverse, "; "))
    print("\nAre you sure? (y/n)")
    resp = io.stdin:read("*l")
    if resp == 'y' or resp == 'Y' then
      for _,file in pairs(inverse) do
        print("Deleting " .. file)
        os.remove (root .. dir .. file)
      end
    end
  end
end

---[=[
-- function that removes all trailing _ and moves lyric files to
-- their respective search_site dir
local function replaceLyrics()
  for file in lfs.dir(LYRICS_DIR) do
    local site, artist, title, ext = file:match('^_*(.*)_' .. artist_title_ext)
    if site and artist and title and (ext == 'html' or ext == 'txt') then
      local old = F(LYRICS_DIR, file)
      local new = F(LYRICS_DIR, site, string.format([[%s - %s.%s]], artist, title, ext))
      print('\n', old, new)
      -- If renaming doesn't work for some reason, try copying
      local succ, mess, errCode =  os.rename(old, new)
      if succ then
        print(string.format('Successfully moved file to "%s"', new))
      end
      print(succ, mess, errCode)
      if errCode == 17 then -- 17: file already exists
        print('removing ' .. old)
        os.remove(old)
      end
      --os.execute(string.format('copy "%s" "%s"', old, new))
    end
  end
end
--]=]

if not APPLOADED then
  --replaceLyrics()
  --fileStr = [[10CC - Dreadlock Holiday]]
  --print(extractFromFile(fileStr))
end