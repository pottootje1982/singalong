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

local playlistMenu = iup.menu {
  iup.item {
    title = "Preview";
    action = function(self)
      local selMp3, selMp3s = widget:getSelection(mp3s)
      if selMp3s then
        getPdfGenerator().generateSongbook(selMp3s, 'temp')
      end
    end;
  },
  iup.item {
    title = "Re-extract lyrics";
    action = function(self)
      local selMp3, selMp3s = widget:getSelection(mp3s)
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
                  0, 0)

      if ret == 0 or not ret then return end -- dialog was cancelled

      local selMp3, selMp3s = widget:getSelection(mp3s)
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
      widget:editOrAddEntry(#mp3s + 1, true)
    end;
  },
  iup.item {
    title = "Remove";
    action = function(self)
      table.remove(mp3s, widget.lastSel)
      widget:modifySelection(math.max(widget.lastSel-1, 1))
      updateGui('playlist', 'searchsites', {true}, 'lyrics')
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
    title = "Play on youtube";
    action = function(self)
      widget:playOnYoutube()
    end;
  },
  -- Actually this function should somewhere in a menu or so, it doesn't operate on selection
  iup.item {
    title = "Write unfound songs to playlist",
    action = function(self)
      local notFoundPlaylist = '#EXTM3U\n'
      local unfoundMp3s = table.ifilter(mp3s, function(i,mp3) return not cache.IsTxtInCache(mp3) end)
      for i, mp3 in ipairs(unfoundMp3s) do
        notFoundPlaylist = notFoundPlaylist .. (mp3.playlistEntry or '')
      end
      os.writeTo(playlist_api.getNotFoundPlaylistName(), notFoundPlaylist)
    end;
  },
}

function playlist:queryGoogle(show)
  local selMp3, selMp3s = self:getSelection(mp3s)
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

function playlist:dropFiles(files)
  print(files)
end

function playlist:playOnYoutube()
  local content, fn = widget:queryGoogle(false)
  local ref = content:match(YOUTUBE_MATCH)
  os.shellExecute(ref, 'html')
end

function playlist:onPopup()
  local selMp3, selMp3s = playlist_gui.widget:getSelection(mp3s)
  local index = 1
  while playlistMenu[index] do
    playlistMenu[index].active = selMp3 and 'YES' or 'NO'
    index = index + 1
  end
  playlistMenu:popup(iup.MOUSEPOS, iup.MOUSEPOS);
end

function playlist:onSelectionChanged(line)
  local mp3 = mp3s[tonumber(line)]
  if mp3 then
    updateGui('searchsites', {true}, 'lyrics' )
  end
end

function playlist:editOrAddEntry(line, add)
  local ret, artist, title =
  iup.GetParam(add and "Add entry" or "Change fields (for web search only)", iupParamCallback,
                  add and "Artist name: %s\n" ..
                          "Title name: %s\n"
                  or      "Change artist name: %s\n" ..
                          "Change title name: %s\n",
                  add and '' or (mp3s[line].customArtist or mp3s[line].artist),
                  add and '' or (mp3s[line].customTitle or mp3s[line].title))

  if ret == 0 or not ret then return end -- dialog was cancelled

  if artist == '' or title == '' then
    iup.Message('Warning', 'Artist or title field cannot be empty!')
  else
    -- remove newlines (This can happen when user presses enter to close dialog)
    artist = artist:gsub('\n', '')
    title = title:gsub('\n', '')
    if mp3s[line] then
      mp3s[line].customArtist = artist
      mp3s[line].customTitle = title
    else
      mp3s[line] = {artist = artist, title = title}
    end

    self:update()
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
  local temp = mp3s[draggedItem]
  table.remove(mp3s, draggedItem)
  table.insert(mp3s, droppedOnItem, temp)
  update()
end

function playlist:updateItem(i, mp3, dontUpdate)
  -- Check if lyrics do not exist
  local exists
  if not i then
    i = table.find(mp3s, mp3)
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
  self.c.numlin = #mp3s
  for i, mp3 in ipairs(mp3s) do
    self.c[i .. ':0'] = tostring(i)
    self.c[i .. ':1'] = mp3.customArtist or mp3.artist
    self.c[i .. ':2'] = mp3.customTitle or mp3.title
    self:updateItem(i, mp3, true)
  end

  self.c[#mp3s + 1 .. ':0'] = nil
  if self.lastSel then
    iup.Update(widget.c)
  end
end

function playlist:k_any(key, press)
  if (key == iup.K_cc or key == iup.K_cC) then
    local playlistContent = ''
    local selMp3, selMp3s = self:getSelection(mp3s)
    for i, mp3 in ipairs(selMp3s) do
      playlistContent = playlistContent .. mp3.artist .. ' - ' .. mp3.title .. '\n'
    end
    clipboard.set(playlistContent)
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
