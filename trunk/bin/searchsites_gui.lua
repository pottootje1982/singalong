module('searchsites_gui', package.seeall)

require 'list'

class 'siteslist' (list)

function siteslist:siteslist(params)
  self:list(params)
  self.c['0:0'] = '#'
  self.c['0:1'] = 'Site'
  self.c['alignment1'] = 'aleft'
  self.c['width0'] = 20
  self.c['width1'] = 100
end

widget = siteslist({readonly = 'yes', minsize = '10x', numcol=1, numlin=#search_sites, expand="vertical", markmode='lin', multiple='yes', disableDragging = true, resizematrix = 'yes', fittosize = 'columns'})

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
  local selMp3, selMp3s = playlist_gui.widget:getSelection(mp3s)
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

  searchSiteMenu:popup(iup.MOUSEPOS, iup.MOUSEPOS);
end

function siteslist:viewFile(ext)
  local selMp3 = playlist_gui.widget:getSelection(mp3s)
  local selSite = self:getSelection(search_sites)

  if selMp3 and selSite then
    local info = cache.scanCache(selMp3, selSite)

    if info and os.exists(info[ext]) then
      os.shellExecute(info[ext])
    end
  end
end

function siteslist:selectFile(ext)
  local selMp3 = playlist_gui.widget:getSelection(mp3s)
  local selSite = widget:getSelection(search_sites)
  if selMp3 and selSite then
    os.shellExecute(os.format_file(ext, selSite, selMp3), nil, 'select')
  end
end

function siteslist:onDouble()
  self:viewFile('html')
end

function siteslist:deleteFile(ext)
  local selMp3, selMp3s = playlist_gui.widget:getSelection(mp3s)
  local selSite, selSites = searchsites_gui.widget:getSelection(search_sites)
  for i, site in ipairs(selSites) do
    local fn, content, info = query.getLyrics(ext, site, selMp3)
    cache.removeFromCache(info, ext)
  end
  updateGui('playlist', 'searchsites', 'lyrics')
end

function siteslist:update(updatePos)
  local found
  local selMp3 = playlist_gui.widget:getSelection(mp3s)
  local artist, title
  if selMp3 then
    selMp3.sitesSucceeded = selMp3.sitesSucceeded or {}
    artist = selMp3.artist
    title = selMp3.title
  end
  for i, search_site in pairs(search_sites) do
    self.c[i .. ':0'] = tostring(i)
    self.c[i .. ':1'] = search_site.site

    local htmlFile, _, info = query.getLyrics('html', search_site, selMp3 or {})
    local txtFile, _, info = query.getLyrics('txt', search_site, selMp3 or {})

    if lyrics_gui.htmlToggle.value == 'ON' and htmlFile and not txtFile then
      -- display item in red if html file is present and no txt could be found (only when htmlToggle is on)
      -- Since getLyrics is implemented with cache, this case can never happen because html item is only set when txt file was found (see cache.buildCache)
      self.c['bgcolor' .. i .. ':1'] = '255 150 150'
    elseif (lyrics_gui.htmlToggle.value == 'ON' and htmlFile or txtFile) then
      if info and not info.ignore then
        if not found then found = i end
        -- display item in green if html and txt were found
        self.c['bgcolor' .. i .. ':1'] = '150 255 150'
      elseif info and info.ignore then
        -- display item in yellow if html and txt were found, but not selected for songbook
        self.c['bgcolor' .. i .. ':1'] = '255 255 150'
      else
        -- display item in white if nothing was found
        self.c['bgcolor' .. i .. ':1'] = '255 255 255'
      end
    else
      -- display item in white if nothing was found
      self.c['bgcolor' .. i .. ':1'] = '255 255 255'
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
      local selMp3 = playlist_gui.widget:getSelection(mp3s)
      local selSite = widget:getSelection(search_sites)
      selMp3.sitesSucceeded[selSite.site] = 'good'
    end;
  }
reasonableItem =
  iup.item {
    title = "Rank as reasonable";
    action = function(self)
      local selMp3 = playlist_gui.widget:getSelection(mp3s)
      local selSite = widget:getSelection(search_sites)
      selMp3.sitesSucceeded[selSite.site] = 'reasonable'
    end;
  }
discardItem =
  iup.item {
    title = "Discard";
    action = function(self)
      local selMp3 = playlist_gui.widget:getSelection(mp3s)
      local selSite = widget:getSelection(search_sites)
      selMp3.sitesSucceeded[selSite.site] = nil
    end;
  }

selectLyricsItem = iup.item {
  title = "Select these lyrics for songbook";
  action = function(self)
    local selMp3 = playlist_gui.widget:getSelection(mp3s)
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
    local selMp3, selMp3s = playlist_gui.widget:getSelection(mp3s)
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
    iup.GetParam("Set beginning/ending search queries of lyrics in html page", iupParamCallback,
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

local scores = {['good']=1, ['reasonable']=0.8}
calcRankSitesButton = iup.button
{
  title="Rank sites",
  expand='HORIZONTAL',
  action=function()
    for _, search_site in pairs(search_sites) do
      search_site.score = 0
      search_site.missed = 0
      search_site.found = 0
      search_site.reasonable = 0
    end
    local selMp3, selMp3s = playlist_gui.widget:getSelection(mp3s)
    for _, mp3 in pairs(selMp3s) do
      if mp3.sitesSucceeded then
        for i, search_site in pairs(search_sites) do
          local rank = mp3.sitesSucceeded[search_site.site]
          local score = scores[rank] or 0
          if rank == 'reasonable' then search_site.reasonable = search_site.reasonable + 1 end
          search_site.score = search_sites[i].score + score
          if query.getLyrics('txt', search_site, mp3) then
            search_site.found = search_site.found + 1
            if rank == nil then
              search_site.missed = search_site.missed + 1
              print(mp3.artist, mp3.title, search_site.site)
            end
          end
        end
      end
    end
    table.sort(search_sites, function(a,b) return a.score > b.score end)
    local display = ''
    for _, search_site in pairs(search_sites) do
      display = string.format('%s%25.25s: %5.1f %5.2f %5.d\n', display, search_site.site, search_site.score, search_site.missed/search_site.found * 100, search_site.reasonable)
    end

    local rankPopup = iup.dialog
    {
      title="Site order",
      iup.label{title=display, font="COURIER_NORMAL_8"},
      size = "100x100"
    }
    rankPopup:popup(iup.center, iup.center)
  end
}
