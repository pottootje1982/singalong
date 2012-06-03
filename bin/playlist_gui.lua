module('playlist_gui', package.seeall)

require 'list'
require 'class'

class 'playlist' (list)

YOUTUBE_MATCH = [[<a href="([^"]*www.youtube.com[^"]+)"]]

local COLUMN0_SIZE = 20

function playlist:playlist(params)
  self:list(params)
  self.c['0:0'] = 'Track'
  self.c['0:1'] = 'Artist'
  self.c['0:2'] = 'Title'
  self.c['alignment1'] = 'aleft'
  self.c['alignment2'] = 'aleft'
end

function playlist:removeSelItem()
  local tracks = playlist_api.getPlaylist()
  local selTrack, selTracks = getSelection()
  for i, track in ipairs(selTracks) do
    local index = table.find(tracks, track)
    table.remove(tracks, index)
  end
  self:modifySelection(math.min(self.lastSel, #tracks))
  updateGui('title_bar', {true}, 'playlist', 'searchsites', {true}, 'lyrics')
end

local playlistMenu = iup.menu {
  iup.item {
    title = "Preview";
    action = function(self)
      local selMp3, selMp3s = getSelection()
      if selMp3s then
        getPdfGenerator().generateSongbook(selMp3s, 'temp')
      end
    end;
  },
  iup.item {
    title = "Re-extract lyrics";
    action = function(self)
      local selMp3, selMp3s = getSelection()
      if selMp3s then
        for i, mp3 in ipairs(selMp3s) do
          for j, search_site in ipairs(search_sites) do
            query.extractLyrics(search_site, selMp3, true)
          end
        end
      end
      updateGui('playlist', 'searchsites', 'lyrics')
    end;
  },
  iup.item {
    title = "Remove txt/html files";
    action = function(self)
      local ret, removeTxt, removeHtml = iup.GetParam("Remove txt/html files", iupParamCallback,
                  "Txt files: %b\n" ..
                  "Html files: %b\n",
                  1, 1)

      if ret == 0 or not ret then return end -- dialog was cancelled

      local selMp3, selMp3s = getSelection()
      if selMp3s then
        for i, mp3 in ipairs(selMp3s) do
          for j, search_site in ipairs(search_sites) do
            local info = cache.scanCache(mp3, search_site)
            if removeTxt == 1 then
              cache.removeFromCache(info, 'txt')
            end
            if removeHtml == 1 then
              cache.removeFromCache(info, 'html')
            end
          end
        end
      end
      updateGui('playlist', 'searchsites', 'lyrics')
    end;
  },
  iup.separator{},
  iup.item {
    title = "Add";
    action = function(self)
      widget:editOrAddEntry()
    end;
  },
  iup.item {
    title = "Remove";
    action = function(self)
      widget:removeSelItem()
    end;
  },
  iup.separator{},
  iup.item {
    title = "Search with google for artist - title";
    action = function(self)
      widget:queryGoogle(true)
    end;
  },
  iup.item {
    title = "Play on youtube",
    action = function(self)
      widget:playOnYoutube()
    end
  },
  iup.item {
    title = "Play in audio player",
    action = function(self)
      local selTrack, selTracks = getSelection()
      playInAudioPlayer(selTracks)
    end
  },
}

function playInAudioPlayer(selTracks)
  local args = ''
  for i, track in ipairs(selTracks) do
    local playlistEntry = track.playlistEntry
    if playlistEntry then
      local playlistEntry, track, pathEntry = string.match(playlistEntry, playlist_api.M3U_ENTRY_MATH)
      args = string.format('%s %q', args, pathEntry)
    end
  end
  if not string.isStringEmptyOrSpace(args) then
    local path, file = os.getPath(config.audioPlayerLocation)
    os.shellExecute(args, file, nil, path)
  end
end

function playlist:queryGoogle(show)
  local selMp3, selMp3s = getSelection()
  local content, fn

  local queryGoogle = function()
    content, fn = query.executeQuery(nil, selMp3, true)
    if fn and os.exists(fn) then
      -- remove /url?q=] from html because this breaks links that have image thumbnail
      content = content:gsub([[/url%?q=]], [[]])
      os.writeTo(fn, content)
      if show then
        os.shellExecute(fn)
      end
    end
  end

  if app then
    local execRoutine = app.addCo(queryGoogle)
    app.waitToFinish(execRoutine)
  else
    queryGoogle()
  end
  return content, fn
end

function fileStringToTable(fileList)
  local result = {}
  for line in fileList:gmatch('[^%c]+') do
    table.insert(result, line)
  end
  return result
end

function playlist:dropFiles(fileList)
  local files = fileStringToTable(fileList)
  assert(files)
  local newSongs = {}
  for i, file in ipairs(files) do
    local attribs = lfs.attributes(file)
    local songs
    if not attribs then
    elseif attribs.mode == 'file' then
      songs = {file}
    elseif attribs.mode == 'directory' then
      songs = os.gatherFiles(file, 'mp3')
    end
    assert(songs)
    songs = playlist_api.gatherMp3InfoFromFiles(songs)
    newSongs = table.imerge(newSongs, songs)
  end
  playlist_api.addToPlaylist(newSongs)
end

function playlist:playOnYoutube()
  local content, fn = widget:queryGoogle(false)
  local ref = content:match(YOUTUBE_MATCH)
  os.shellExecute(ref, 'html')
end

function playlist:onPopup()
  local selMp3, selMp3s = playlist_gui.getSelection()
  local index = 1
  while playlistMenu[index] do
    playlistMenu[index].active = selMp3 and 'YES' or 'NO'
    index = index + 1
  end
  playlistMenu:popup(iup.MOUSEPOS, iup.MOUSEPOS);
end

function playlist:onSelectionChanged(line)
  local tracks = playlist_api.getPlaylist()
  local track = tracks[tonumber(line)]
  if track then
    updateGui('searchsites', {true}, 'lyrics' )
  end
end

function playlist:editOrAddEntry(line)
  local add = not line
  local tracks = playlist_api.getPlaylist()
  line = line or (#tracks + 1)
  local track = tracks[line]
  local ret, artist, title =
  iup.GetParam(add and "Add entry" or "Change fields (for web search only)", iupParamCallback,
                  add and "Artist name: %s\n" ..
                          "Title name: %s\n"
                  or      "Change artist name: %s\n" ..
                          "Change title name: %s\n",
                  add and '' or (track.customArtist or track.artist),
                  add and '' or (track.customTitle or track.title))

  if ret == 0 or not ret then return end -- dialog was cancelled

  if artist == '' or title == '' then
    iup.Message('Warning', 'Artist or title field cannot be empty!')
  else
    -- remove newlines (This can happen when user presses enter to close dialog)
    artist = artist:gsub('\n', '')
    title = title:gsub('\n', '')
    if track then
      -- if track already resides in cache, we only adapt customArtist/customTitle,
      -- which is only used for visual representation and querying
      if cache.IsTxtInCache(track) then
        track.customArtist = artist
        track.customTitle = title
      else
        track.artist = artist
        track.title = title
      end
    else
      track = {artist = artist, title = title}
      tracks[line] = track
    end
    cache.rescanPlaylist({track})
    playlist_api.playlistUpdate(true)
  end
end

function playlist:onDouble(line)
  if line == 0 then
    self.c.fittotext = 'C1'
    self.c.fittotext = 'C2'
  else
    self:editOrAddEntry(line)
  end
end

function playlist:onDraggingStopped(draggedItem, droppedOnItem)
  local tracks = playlist_api.getPlaylist()
  local temp = tracks[draggedItem]
  table.remove(tracks, draggedItem)
  table.insert(tracks, droppedOnItem, temp)
  update()
end

function playlist:updateItem(i, mp3, dontUpdate)
  -- Check if lyrics do not exist
  local tracks = playlist_api.getPlaylist()
  local exists
  if not i then
    i = table.find(tracks, mp3)
  end
  exists = cache.IsTxtInCache(mp3)
  if not exists then
    self.c['bgcolor' .. i .. ':1'] = '255 150 150'
    self.c['bgcolor' .. i .. ':2'] = '255 150 150'
  else
    self.c['bgcolor' .. i .. ':1'] = '255 255 255'
    self.c['bgcolor' .. i .. ':2'] = '255 255 255'
  end
  if not dontUpdate then
    iup.Update(self.c)
  end
end

function playlist:update()
  local tracks = playlist_api.getPlaylist()
  self.c.numlin = #tracks
  for i, mp3 in ipairs(tracks) do
    self.c[i .. ':0'] = tostring(i)
    self.c[i .. ':1'] = mp3.customArtist or mp3.artist
    self.c[i .. ':2'] = mp3.customTitle or mp3.title
    self:updateItem(i, mp3, true)
  end

  self.c[#tracks + 1 .. ':0'] = nil
  if self.lastSel then
    iup.Update(widget.c)
  end
end

function playlist:k_any(key, press)
  if (key == iup.K_cc or key == iup.K_cC) then
    local playlistContent = ''
    local selMp3, selMp3s = getSelection()
    for i, mp3 in ipairs(selMp3s) do
      playlistContent = playlistContent .. mp3.artist .. ' - ' .. mp3.title .. '\n'
    end
    clipboard.set(playlistContent)
  elseif key == iup.K_DEL then
    self:removeSelItem()
  elseif key == iup.K_INS then
    self:editOrAddEntry()
  elseif key == iup.K_F2 then
    self:editOrAddEntry(self.lastSel)
  end
end

function update()
  widget:update()
end

widget = playlist({readonly = 'yes', minsize = '100x', numcol=2, markmode='lin', multiple='yes', autoredraw = 'yes', border = 'yes', numcol_visible=2, resizematrix = 'yes', })

function resize_cb()
  --widget.c.fittosize = 'columns'
  widget.c.fittotext = 'C1'
  widget.c.fittotext = 'C2'
end

function getSelection(trks)
  local allTracks = playlist_api.getPlaylist()
  return widget:getSelection(trks or allTracks)
end
