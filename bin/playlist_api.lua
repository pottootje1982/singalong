module('playlist_api', package.seeall)

require 'query'
require 'misc'
require 'spotify_playlist'
require 'playlist_helpers'
require 'id3'

local playlistFileName
local playlist = {}

M3U_ENTRY_MATH = "(#EXTINF:[%d]+,([^%c]*)\n([^%c]*)\n)"

local function setPlaylistFileName(fn)
  if mainDialog then mainDialog.title = 'SinGaLonG' .. ' - ' .. tostring(fn) end
  playlistFileName = fn
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
    -- If binary loading fails, try to load it as text:
    if not mp3Info then
      mp3Info = dofile(singFile)
    end
    return mp3Info
  end
end

-- save mp3 table that contains ranking info of search sites
function saveMp3Table(fn, mp3Table)
  fn = fn or playlistFileName
  mp3Table = mp3Table or playlist_api.getPlaylist()
  if mp3Table and #mp3Table > 0 and fn then
    table.saveToFile(os.getFileWithoutExt(fn) .. '.sing', mp3Table)
  end
  updateGui('title_bar', 'lyrics')
end


local function openTXT(fn)
  file = io.open(fn)
  assert(file, string.format("File %q doesn't exist!", fn))
  local content = file:read("*a")
  local tracks = playlist_helpers.gatherFromCustomPlaylist(content)
  return tracks
end

local function showNewPlaylistDialog()
  local filedlg = iup.filedlg{dialogtype = "SAVE", title = "Save new playlist as",
                        extfilter = "SingAlonG Playlists (*.sing)|*.sing;|"}
  filedlg:popup (iup.ANYWHERE, iup.ANYWHERE)
  if filedlg.status == '1' or filedlg.status == '0' then -- 1: new file, 0: existing
    return filedlg.value
  end
end

function makeNewPlaylist(add)
  local sample = [[The Beatles - Yellow Submarine
Neil Young - Old man
]]

  local clipboardContent = clipboard.get()
  if clipboardContent and clipboardContent:find('open.spotify.com', nil, true) then sample = clipboardContent end

  local res, playlistEntries = require 'playlist_dlg'(sample)

  if not playlistEntries then return end

  if add then
    addToPlaylist(playlistEntries)
  else
    local playlistName = showNewPlaylistDialog()
    if not playlistName then return end
    if os.getExtension(playlistName) ~= 'sing' then playlistName = playlistName .. '.sing' end
    if not os.isFileWritable(playlistName) then iup.Message('Warning', string.format('Cannot write to file "%s"! Make sure it is not write protected.', playlistName)) return end

    -- Save currently loaded mp3 table
    saveMp3Table()
    -- Save new custom playlist
    saveMp3Table(playlistName, playlistEntries)
    openPlaylist(playlistName, true, table.isEmpty(playlistEntries))
  end
end

local function showOpenPlaylistDialog()
  local filedlg = iup.filedlg{dialogtype = "OPEN", title = "Open playlist",
                        extfilter = "All Playlist Types (*.sing; *.m3u; *.m3u8; *.txt)|*.sing;*.m3u;*.m3u8;*.txt|SingAlonG Playlists (*.sing)|*.sing;|Playlists (*.m3u)|*.m3u;|m3u8 Playlists (*.m3u8)|*.m3u8;|Text Files (*.txt)|*.txt;|"}
  filedlg:popup (iup.ANYWHERE, iup.ANYWHERE)
  if filedlg.status == '0' then
    return filedlg.value
  end
end

function openPlaylist(fn, newSingFile, clearPlaylist)
  if not fn then
    fn = showOpenPlaylistDialog()
  end
  if fn and os.exists(fn) then
    os.calcTime('open playlist', function()

      local reloadM3u = false
      local strippedFile, ext = os.getFileWithoutExt(fn)
      local singFile = strippedFile .. '.sing'
      if (ext == '.m3u' or ext=='.m3u8') and os.exists(singFile) then
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

      local tracks
      if not reloadM3u then
        local newMp3s = loadMp3Table(singFile)
        if not newMp3s then
          iup.Message('Warning', string.format('Loading of sing file "%s" failed!', singFile))
          return
        end
        tracks = newMp3s
      end

      setPlaylistFileName(fn)

      if ext == '.m3u' or ext == '.m3u8' and reloadM3u then
        tracks = gatherMp3Info(fn)
      elseif ext == '.txt' then
        tracks = openTXT(fn)
      elseif ext == '.sing' then -- do nothing, sing files will be opened in loadMp3Table()
      end

      if clearPlaylist then
        tracks = {}
      end

      setPlaylist(tracks)
    end)
  end
end

function playlistUpdate(playlistModified)
  updateGui('title_bar', {playlistModified}, 'playlist', 'searchsites', 'lyrics')
  playlist_gui.resize_cb()
end

function setPlaylist(tracks)
  playlist = tracks
  playlistUpdate()
  playlist_gui.widget:modifySelection(1)
  cache.rescanPlaylist(tracks)
end

function addToPlaylist(newTracks)
  playlist = table.imerge(playlist, newTracks)
  playlistUpdate(true)
  cache.rescanPlaylist(newTracks)
end

function getPlaylist()
  return playlist
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
  local content = file:read("*a")
  local result = {}
  for v in (string.gmatch(content, "#EXTINF[^%c]*\n([^%c]*)\n")) do
    table.insert(result, v)
  end
  return result
end

local function getArtistTitleFromFile(pathEntry)
  local artist, title, album
  local path, fileStr = pathEntry:match("(.-)([^:\\/]+)%.[^.]+$")

  if fileStr then
    artist, title = playlist_helpers.extractArtistTitle(fileStr)
    if not artist then
      artist, album = path:match([[([^\/-]-)%s+%-%s+([^\/-]*)]])
      if artist then
        title = fileStr:match("[%d]+[%.]* (.*)")
      end
    end
  end
  return artist, title
end

local function addTrack(tracks, artist, title, file)
  if artist and title then
    file = os.makeAbsolute(file, playlist_api.getPlaylistName())
    local track = {artist = artist, title = title, file = file, id3=id3.readtags(file)}
    table.insert(tracks, track)
    return track
  end
end

function gatherMp3Info(fn)
  file = io.open(fn)
  assert(file, string.format("File %q doesn't exist!", fn))
  content = file:read("*a")
  tracks = {}
  for playlistEntry, track, pathEntry in (string.gmatch(content, M3U_ENTRY_MATH)) do
    local artist, title
    artist, title = playlist_helpers.extractArtistTitle(track)
    if not artist or not title then
      artist, title = getArtistTitleFromFile(pathEntry)
    end
    local newTrack = addTrack(tracks, artist, title, pathEntry)
    if newTrack then newTrack.playlistEntry = playlistEntry end
  end
  -- Try to open it as txt file (m3u can also contain file entries only)
  if table.isEmpty(tracks) then
    local files = playlist_helpers.fileStringToTable(content)
    tracks = gatherMp3InfoFromFiles(files)
  end

  return tracks
end

function gatherMp3InfoFromFiles(files)
  local tracks = {}
  for i, file in ipairs(files) do
    local artist, title = getArtistTitleFromFile(file)
    addTrack(tracks, artist, title, file)
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

function deleteNotInPlayList(tracks, root, fn)
  dirs = extractDirs(tracks)
  for _,dir in pairs(dirs) do
    inverse = gatherInverse(root, dir, tracks)
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
