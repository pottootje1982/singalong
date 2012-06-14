module('playlist_gui', package.seeall)

require 'list'
require 'class'
require 'playlist_helpers'

class 'playlist' (list)

YOUTUBE_MATCH = [[<a href="([^"]*www.youtube.com[^"]+)"]]

local COLUMN0_SIZE = 20

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
      local ret, removeTxt, removeHtml = iup.GetParam("Remove txt/html files", nil,
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
      editOrAddEntry()
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
    title = "Search google for lyrics";
    action = function(self)
      widget:queryGoogle(true, 'lyrics')
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
  iup.item {
    title = "Save as playlist",
    action = function(self)
      local selTrack, selTracks = getSelection()
      saveAsPlaylist(selTracks)
    end
  },
  iup.separator{},
  iup.item {
    title = "Show track in explorer",
    action = function(self)
      local selTrack, selTracks = getSelection()
      if selTrack.file then os.shellExecute(selTrack.file, nil, 'select') end
    end
  },
}

function playlist:playlist(params)
  self:list(params)
  self:setValue('Track',  0,0)
  self:setValue('Artist', 0,1)
  self:setValue('Title',  0,2)
  self:setValue('Album',  0,3)
  self:setAttribute('alignment', 'aleft', 1)
  self:setAttribute('alignment', 'aleft', 2)
  self:setAttribute('alignment', 'aleft', 3)
  self.popup = playlistMenu
  --self.c['sortsign1'] = 'yes'
  --self.c['sortsign2'] = 'yes'
  --self.c['sortsign3'] = 'yes'
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

function playInAudioPlayer(selTracks)
  local args = ''
  for i, track in ipairs(selTracks) do
    local file = track.file
    if file then
      args = string.format('%s %q', args, file)
    end
  end
  assert(not string.isStringEmptyOrSpace(args), 'No files could be found from selection')
  local errorMessage = string.format("Audio player %q couldn't be found!", config.audioPlayerLocation)
  assert(os.exists(config.audioPlayerLocation), errorMessage)
  local _, file = os.getPath(config.audioPlayerLocation)
  local path = os.getPath(playlist_api.getPlaylistName())
  os.shellExecute(args, config.audioPlayerLocation, nil, path, true)
end

function saveAsPlaylist(selTracks)
  local playlist = ''
  for i, track in ipairs(selTracks) do
    playlist = playlist .. track.file .. '\n'
  end
  local res = playlist_api.showNewPlaylistDialog(nil, "Playlists (*.m3u)|*.m3u;|")
  if res then
    os.writeTo(res, playlist)
  end
end

-- remove /url?q=] from html because this breaks links that have image thumbnail
function fixUrls(htmlContent)
  return htmlContent:gsub('/url%?q=(.-)&amp;.-%"', '%1"')
end

function playlist:queryGoogle(show, appendix)
  local selMp3, selMp3s = getSelection()
  local content, fn

  local queryGoogle = function()
    content, fn = query.executeQuery(nil, selMp3, true, appendix)
    if fn and os.exists(fn) then
      content = fixUrls(content)
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

function playlist:dropFiles(files, index)
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
  playlist_api.addToPlaylist(newSongs, index)
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
end

function playlist:onSelectionChanged(line)
  local tracks = playlist_api.getPlaylist()
  local track = tracks[tonumber(line)]
  if track then
    updateGui('searchsites', {true}, 'lyrics' )
  end
end

function editEntry(line)
  local selTrack, selTracks = getSelection()
  if #selTracks == 1 then
    editOrAddEntry(line)
  elseif #selTracks > 1 then
    editArtistSelection(selTracks)
  end
end

function editArtistSelection(selTracks)
  local ret, artist =
  iup.GetParam( "Change artist value (for web search only)", nil,
                "Change artist name: %s\n", selTracks[1].customArtist or selTracks[1].artist)
  if ret == 0 or not ret then return end -- dialog was cancelled
  if string.isStringEmptyOrSpace(artist) then
    iup.Message('Warning', 'Artist field cannot be empty!')
  else
    for i, track in ipairs(selTracks) do
      if cache.IsTxtInCache(track) then
        track.customArtist = artist
      else
        track.artist = artist
      end
    end
    cache.rescanPlaylist(selTracks)
    playlist_api.playlistUpdate(true)
  end
end

function editOrAddEntry(line)
  local tracks = playlist_api.getPlaylist()
  line = line or (#tracks + 1)
  local track = tracks[line]
  local ret, artist, title =
  iup.GetParam(add and "Add entry" or "Change fields (for web search only)", nil,
                  add and "Artist name: %s\n" ..
                          "Title name: %s\n"
                  or      "Change artist name: %s\n" ..
                          "Change title name: %s\n",
                  add and '' or (track.customArtist or track.artist),
                  add and '' or (track.customTitle or track.title))

  if ret == 0 or not ret then return end -- dialog was cancelled

  if string.isStringEmptyOrSpace(artist) or string.isStringEmptyOrSpace(title) then
    iup.Message('Warning', 'Artist or title field cannot be empty!')
  else
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
    editEntry(line)
  end
end

function playlist:onDraggingStopped(draggedItem, droppedOnItem)
  local tracks = playlist_api.getPlaylist()
  local temp = tracks[draggedItem]
  table.remove(tracks, draggedItem)
  table.insert(tracks, droppedOnItem, temp)
  update()
end

function playlist:setRowColor(row, color)
  for column = 1, self.c.numcol do
    self.c['bgcolor' .. row .. ':' .. column] = color
    column = column + 1
  end
end

function playlist:updateItem(i, mp3, dontUpdate)
  -- Check if lyrics do not exist
  local tracks = playlist_api.getPlaylist()
  local exists
  if not i then
    i = table.find(tracks, mp3)
    if not i then return end
  end
  exists = cache.IsTxtInCache(mp3)
  self:setRowColor(i, exists and WHITE or RED)
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
    self.c[i .. ':3'] = mp3.id3 and mp3.id3.album
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
    editOrAddEntry()
  elseif key == iup.K_F2 then
    editEntry(self.lastSel)
  else
    return iup.CONTINUE
  end
  return iup.IGNORE
end

function update()
  widget:update()
end

widget = playlist({readonly = 'yes', minsize = '100x', numcol=3, markmode='lin', multiple='yes', autoredraw = 'yes', border = 'yes', numcol_visible=2, resizematrix = 'yes', })

function resize_cb()
  --widget.c.fittosize = 'columns'
  widget.c.fittotext = 'C1'
  widget.c.fittotext = 'C2'
  widget.c.fittotext = 'C3'
end

function getSelection(trks)
  local allTracks = playlist_api.getPlaylist()
  return widget:getSelection(trks or allTracks)
end

function destroy()
  iup.Destroy(playlistMenu)
end
