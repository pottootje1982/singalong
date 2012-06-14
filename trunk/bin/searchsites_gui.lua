module('searchsites_gui', package.seeall)

require 'list'
require 'lyrics_gui'

class 'siteslist' (list)

local searchSiteMenu

function siteslist:siteslist(params)
  self:list(params)
  self:setValue('#',  0,0)
  self:setValue('Site', 0,1)
  self:setAttribute('alignment', 'aleft', 1)
  self:setAttribute('width', 20, 0)
  self:setAttribute('width', 100, 1)
  self.popup = searchSiteMenu
end

local goodItem
local reasonableItem
local discardItem
local selectLyricsItem
local reextractLyricsItem
local previewItem
local viewTxtItem
local deleteHtmlItem
local deleteTxtItem
local lyricsSearchConfigItem

-- status = "SC123 A45"
-- space is unknown S = shift, C = control, A = alt
function siteslist:onSelectionChanged(line)
  if tonumber(self.c.numlin) > 0 then
    updateGui('searchsites', 'lyrics', {line})
  end
end

function siteslist:onPopup()
  local selMp3, selMp3s = playlist_gui.getSelection()
  local selSite, selSites = self:getSelection(search_sites)
  if selSite and selMp3 and selMp3.sitesSucceeded then
    goodItem.value = selMp3.sitesSucceeded[selSite.site] == 'good' and 'ON' or 'OFF'
    reasonableItem.value = selMp3.sitesSucceeded[selSite.site] == 'reasonable' and 'ON' or 'OFF'
    discardItem.value = selMp3.sitesSucceeded[selSite.site] == nil and 'ON' or 'OFF'
  end

  local selTxtFound, selHtmlFound
  if selMp3 and selSite then
    local info = cache.scanCache(selMp3, selSite)
    selTxtFound = info and info.txt
    selHtmlFound = info and info.html
  end

  local txtFound = table.find(selMp3s or {},
    function(i, mp3)
      for i, site in ipairs(selSites) do
        local info = cache.scanCache(mp3, site)
        return info and info.txt
      end
    end)

  -- disable items if no mp3 is selected or if no html/txt has been found
  selectLyricsItem.active = selTxtFound and 'YES' or 'NO'
  reextractLyricsItem.active = selHtmlFound and 'YES' or 'NO'
  previewItem.active = txtFound and 'YES' or 'NO'
  viewTxtItem.active = selTxtFound and 'YES' or 'NO'
  selectTxtItem.active = selTxtFound and 'YES' or 'NO'
  selectHtmlItem.active = selHtmlFound and 'YES' or 'NO'
  deleteHtmlItem.active = selHtmlFound and 'YES' or 'NO'
  deleteTxtItem.active = selTxtFound and 'YES' or 'NO'
end

function siteslist:viewFile(ext)
  local selMp3 = playlist_gui.getSelection()
  local selSite = self:getSelection(search_sites)

  if selMp3 and selSite then
    local info = cache.scanCache(selMp3, selSite)

    if info and os.exists(info[ext]) then
      os.shellExecute(info[ext])
    end
  end
end

function siteslist:selectFile(ext)
  local selMp3 = playlist_gui.getSelection()
  local selSite = widget:getSelection(search_sites)
  if selMp3 and selSite then
    os.shellExecute(os.format_file(ext, selSite, selMp3), nil, 'select')
  end
end

function siteslist:onDouble()
  self:viewFile(lyrics_gui.htmlToggle.value == 'ON' and 'html' or 'txt')
end

function siteslist:deleteFile(ext)
  local selMp3, selMp3s = playlist_gui.getSelection()
  local selSite, selSites = searchsites_gui.widget:getSelection(search_sites)
  for i, site in ipairs(selSites) do
    local fn, content, info = query.getLyrics(ext, site, selMp3)
    cache.removeFromCache(info, ext)
  end
  updateGui('playlist', 'searchsites', 'lyrics')
end

function siteslist:k_any(key)
  if key == iup.K_DEL then
    siteslist:deleteFile('txt')
    siteslist:deleteFile('html')
  else
    return iup.CONTINUE
  end
  return iup.IGNORE
end

function siteslist:update(updatePos)
  local found
  local selMp3 = playlist_gui.getSelection()
  local artist, title
  if selMp3 then
    selMp3.sitesSucceeded = selMp3.sitesSucceeded or {}
    artist = selMp3.artist
    title = selMp3.title
  end
  for i, search_site in pairs(search_sites) do
    self:setValue(tostring(i), i, 0)
    self:setValue(search_site.site, i, 1)

    local htmlFile, _, info = query.getLyrics('html', search_site, selMp3 or {})
    local txtFile, _, info = query.getLyrics('txt', search_site, selMp3 or {})

    -- White is default color
    self:setAttribute('bgcolor', WHITE, i, 1)
    if lyrics_gui.htmlToggle.value == 'ON' then
      if htmlFile then
        self:setAttribute('bgcolor', GREEN, i, 1)
        if not txtFile then
          -- display item in red if html file is present and no txt could be found (only when htmlToggle is on)
          -- Since getLyrics is implemented with cache, this case can never happen because html item is only set when txt file was found (see cache.buildCache)
          self:setAttribute('bgcolor', RED, i, 1)
        end
      end
    else
      if info and not info.ignore then
        if not found then found = i end
        -- display item in green if html and txt were found
        self:setAttribute('bgcolor', GREEN, i, 1)
      elseif info and info.ignore then
        -- display item in yellow if html and txt were found, but not selected for songbook
        self:setAttribute('bgcolor', YELLOW, i, 1)
      else
      end
    end
  end
  self.c.redraw= 'yes'

  if updatePos then
    widget:modifySelection(found or 1)
  end
end

function update(updatePos)
  widget:update(updatePos)
end

goodItem =
  iup.item {
    title = "Rank as good";
    action = function(self)
      local selMp3 = playlist_gui.getSelection()
      local selSite = widget:getSelection(search_sites)
      selMp3.sitesSucceeded[selSite.site] = 'good'
    end;
  }
reasonableItem =
  iup.item {
    title = "Rank as reasonable";
    action = function(self)
      local selMp3 = playlist_gui.getSelection()
      local selSite = widget:getSelection(search_sites)
      selMp3.sitesSucceeded[selSite.site] = 'reasonable'
    end;
  }
discardItem =
  iup.item {
    title = "Discard";
    action = function(self)
      local selMp3 = playlist_gui.getSelection()
      local selSite = widget:getSelection(search_sites)
      selMp3.sitesSucceeded[selSite.site] = nil
    end;
  }

selectLyricsItem = iup.item {
  title = "Select these lyrics for songbook";
  action = function(self)
    local selMp3 = playlist_gui.getSelection()
    local selSite = searchsites_gui.widget:getSelection(search_sites)
    for i, searchSite in ipairs(search_sites) do
      local cachedItem = cache.scanCache(selMp3, searchSite)
      if cachedItem then
        cachedItem.ignore = searchSite ~= selSite
      end
    end
    update()
  end;
}

reextractLyricsItem = iup.item {
  title = "Re-extract lyrics from html";
  action = function(self)
    local selMp3, selMp3s = playlist_gui.getSelection()
    local selSite, selSites = searchsites_gui.widget:getSelection(search_sites)
    for i, search_site in ipairs(selSites) do
      query.extractLyrics(search_site, selMp3, true)
    end
    updateGui('playlist', 'searchsites', 'lyrics')
  end;
}

previewItem = iup.item {
  title = "Preview";
  action = function(self)
    local selSite, selSites = searchsites_gui.widget:getSelection(search_sites)
    getPdfGenerator().previewSites('temp', selSites)
  end;
}

viewTxtItem = iup.item {
  title = "View txt file";
  action = function(self)
    widget:viewFile('txt')
  end;
}

selectTxtItem = iup.item {
  title = "Select txt file";
  action = function(self)
    widget:selectFile('txt')
  end;
}

selectHtmlItem = iup.item {
  title = "Select html file";
  action = function(self)
    widget:selectFile('html')
  end;
}

deleteHtmlItem = iup.item {
  title = "Delete html file";
  action = function(self)
    widget:deleteFile('html')
  end;
}

deleteTxtItem = iup.item {
  title = "Delete txt file";
  action = function(self)
    widget:deleteFile('txt')
  end;
}

lyricsSearchConfigItem = iup.item {
  title = "Lyrics search configuration";
  action = function(self)
    local selSite = searchsites_gui.widget:getSelection(search_sites)
    local ret, searchSiteBegin, searchSiteEnd =
    iup.GetParam("Set beginning/ending search queries of lyrics in html page", nil,
                    "Begin query (separate with newlines for multiple searches): %m\n" ..
                    "End query: %m\n",
                    table.concat(selSite.lyric_begin, '\n'), selSite.lyric_end)

    if ret == 0 or not ret then return end -- dialog was cancelled

    selSite.lyric_begin = {}
    for query in searchSiteBegin:gmatch('([^\n]+)[\n]*') do
      table.insert(selSite.lyric_begin, query)
    end
    selSite.lyric_end = searchSiteEnd
  end;
}

searchSiteMenu = iup.menu {
  selectLyricsItem,
  reextractLyricsItem,
  iup.separator{},
  previewItem,
  viewTxtItem,
  iup.separator{},
  selectHtmlItem,
  selectTxtItem,
  iup.separator{},
  deleteHtmlItem,
  deleteTxtItem,
  iup.separator{},
  lyricsSearchConfigItem,
  _DEBUG and iup.separator{},
  _DEBUG and goodItem,
  _DEBUG and reasonableItem,
  _DEBUG and discardItem,
}

widget = siteslist({readonly = 'yes', minsize = '10x10', numcol=1, numlin=#search_sites, expand="yes", markmode='lin', multiple='yes', disableDragging = true, resizematrix = 'yes', fittosize = 'columns'})

function destroy()
  iup.Destroy(searchSiteMenu)
end
