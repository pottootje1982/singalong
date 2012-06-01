require 'misc'
require 'playlist_api'
require 'title_bar'
require 'lyrics_gui'

function updateGui(...)
  for i, v in ipairs(arg) do
    local args = {}
    if type(arg[i+1]) == 'table' then
      args = arg[i+1]
    end
    if type(v) == 'string' then
      require(v .. '_gui').update(unpack(args))
    end
  end
end

function activateButtons()
  local tracks = playlist_api.getPlaylist()
  local active = (tracks and #tracks > 0) and 'YES' or 'NO'
  lyrics_gui.saveLyricsButton.active = active
  title_bar.sortButton.active = active
  title_bar.downloadLyricsButton.active = active
  title_bar.createSongbookButton.active = active
end

-- Returns selected site + artist + title
function getSelection(search_site)
  if not search_site then
    search_site = searchsites_gui.widget:getSelection(search_sites)
  end
  local selMp3, selMp3s = playlist_gui.getSelection()
  if search_site and selMp3 then
    return search_site, selMp3.artist, selMp3.title
  end
end

function iupParamCallback(dialog, paramIndex)
  if paramIndex == -2 then -- -2 = after the dialog is mapped and just before it is shown;
    setDialogIcon(dialog)
  end
end

