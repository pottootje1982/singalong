module('lyrics_gui', package.seeall)

require 'searchsites_gui'

lyricsFileNameLabel = iup.label{title = "", expand = "HORIZONTAL"}

saveLyricsButton = iup.button
{
  tip = "Save lyrics",
  active = 'NO',
  image = 'IUP_FileSave',
  action = function()
    local content = lyricsMultiLine.value
    local selSite = searchsites_gui.widget:getSelection(search_sites)
    local selMp3 = playlist_gui.getSelection()
    if selSite and selMp3 then
      local fn = os.format_file(lyrics_gui.htmlToggle.value == 'ON' and 'html' or 'txt', selSite, selMp3)
      cache.addToCache(selMp3, selSite, fn, content)
    end
    updateGui('playlist', 'searchsites')
  end
}

htmlToggle = iup.toggle{title = "Show Html source"}
function htmlToggle:action()
  updateGui('searchsites', 'lyrics')
end

lyricsMultiLine = iup.multiline{value="", border="YES", expand="yes", minsize='10x10', wordwrap='yes'}
function lyricsMultiLine:updateLyrics(searchIndex)
  local selMp3  = playlist_gui.getSelection()
  local selSite = searchsites_gui.widget:getSelection(search_sites)
  if selSite then
    if htmlToggle.value == 'ON' then
      lyricsFileNameLabel.title, self.value = query.getLyrics('html', selSite, selMp3 or {})
    else
      lyricsFileNameLabel.title, self.value = query.getLyrics('txt', selSite, selMp3 or {})
    end
  else
    lyricsMultiLine.value = ''
    lyricsFileNameLabel.title = ''
  end
end

function lyricsMultiLine:k_any( key, press)
  if (key == iup.K_cs or key == iup.K_cS) then
    saveLyricsButton:action()
    return iup.IGNORE
  end
  return iup.CONTINUE
end

function update(searchIndex)
  lyrics_gui.saveLyricsButton.active = active
  lyricsMultiLine:updateLyrics(searchIndex)
end
