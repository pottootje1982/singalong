module('title_bar_gui', package.seeall)

require 'misc'
require 'playlist_api'
require 'playlist_gui'
require 'progress_dialog'
require 'downloader'

local downloadIcon = require 'icon'
local addIcon = require 'add_icon'

local newPlaylistButton = iup.button{title="", image = 'IUP_FileNew', tip="New playlist (ctr-n)"}
local addToPlaylistButton = iup.button{title="", image = addIcon, tip="Add to current playlist"}
local openPlaylistButton = iup.button{title="", image = 'IUP_FileOpen', tip="Open playlist (ctr-o)"}
local savePlaylistButton = iup.button{title="", image = 'IUP_FileSave', tip="Save playlist (ctr-s)"}
local downloadLyricsButton = iup.button{tip="Download lyrics (ctr-d)", image=downloadIcon, active = 'NO'}
local sortButton = iup.button{tip="Sort playlist", image='IUP_ToolsSortAscend', active = 'NO'}
local removeDoublesButton = iup.button{tip="Remove doubles", image='IUP_ZoomActualSize', active = 'NO'}
local createSongbookButton = iup.button{tip="Create songbook (ctr-b)", image = 'IUP_FileText', active = 'NO'}
local settingsButton = iup.button{tip="Settings", image = 'IUP_ToolsSettings', alignment='ARIGHT'}

function newPlaylistButton:action()
  playlist_api.makeNewPlaylist()
  return iup.DEFAULT
end

function addToPlaylistButton:action()
  playlist_api.makeNewPlaylist(true)
end

function openPlaylistButton:action()
  playlist_api.openPlaylist()
  return iup.DEFAULT
end

function savePlaylistButton:action()
  playlist_api.saveMp3Table()
  return iup.DEFAULT
end

local function sortTracks(tracks)
  table.sort(tracks, function(a,b)
    local aartist = a.customArtist or a.artist
    local atitle = a.customTitle or a.title
    local bartist = b.customArtist or b.artist
    local btitle = b.customTitle or b.title
    return (aartist:lower() == bartist:lower() and atitle:lower() < btitle:lower()) or aartist:lower() < bartist:lower()
  end)
  update(true)
end

function sortButton:action()
  local tracks = playlist_api.getPlaylist()
  sortTracks(tracks)
  updateGui('playlist', 'searchsites', 'lyrics')
end

function compareTracks(a,b)
  return string.equals(a.customArtist or a.artist, b.customArtist or b.artist) and string.equals(a.customTitle or a.title, b.customTitle or b.title)
end

function removeDoublesButton:action()
  local tracks = playlist_api.getPlaylist()
  table.removeDoubles(tracks, compareTracks)
  updateGui('playlist', 'searchsites', 'lyrics')
end

local function showCaptchaAssignment()
  local fn = 'temp.html'
  socketinterface.request('http://www.google.com/search?q=The+Beatles+Yellow+Submarine', fn)
  local content = os.read(fn)
  local url, captchaId = content:match('<form action="Captcha"[^>]-><[^>]-value="([^"]+)"[^>]-><[^>]-value="([^"]+)"')
  content = content:gsub('(<img src=")([^"]+)', '%1http://www.google.com%2')
  local baseUrl = content:match('<img src="([^"]+)')
  os.writeTo(fn, content)
  os.shellExecute(fn)
  if url and captchaId then
    local ret, captchaAns = iup.GetParam("Enter Captcha string", nil,
                    "Enter characters from image: %s\n", '')

    if ret == 0 or not ret then return end -- dialog was cancelled

    url = baseUrl ..'/Captcha?continue=' .. url
    local captchUrl = string.format('%s&id=%s&captcha=%s&submit=Submit', url, captchaId, captchaAns)
    print('Trying to resolve CAPTCHA assignment with url:', captchUrl)
    socketinterface.request(captchUrl, 'resol.html')
  end
end

function downloadLyricsButton:action()
  downloader.downloadLyrics(mainDialog.title)
end

function createSongbookButton:action()
  createSongbook()
end

function createSongbook()
  local function num(bool) return bool and 1 or 0 end
  local pdfGenerator = table.find(pdfGenerators, config.pdfGenerator)
  assert(pdfGenerator, 'PDF generator ' .. tostring(config.pdfGenerator) .. ' is unknown!')
  local fontSize = table.find(fontSizes, config.fontSize)
  assert(fontSize, 'Font size ' .. tostring(config.fontSize) .. ' is unknown!')
  local ret, pdfGenerator, texifySelMp3s, fontSize, fontColor, twoside, avoidPageBreaks, preview =
    iup.GetParam("Create songbook", nil,
                      "PDF generator: %l"  .. table.zeroConcat(pdfGenerators, '|') .. "\n"..
                      "Use selected songs only: %b\n" ..
                      "%t\n" ..
                      "Font size (pts): %l" .. table.zeroConcat(fontSizes, '|') .. "\n" ..
                      "Font color: %c\n" ..
                      "Two sided page layout: %b\n" ..
                      "Try to avoid page breaks within lyrics: %b\n" ..
                      "Preview: %b\n",
                      pdfGenerator,
                      num(config.texifySelMp3s),
                      fontSize,
                      config.fontColor,
                      num(config.twoside),
                      num(config.avoidPageBreaks),
                      num(config.preview))
  if not ret then return end
  config.pdfGenerator = pdfGenerators[pdfGenerator]
  config.texifySelMp3s = texifySelMp3s == 1
  config.fontSize = fontSizes[fontSize]
  config.fontColor = fontColor
  config.twoside = twoside == 1
  config.avoidPageBreaks = avoidPageBreaks == 1
  config.preview = preview == 1

  local selMp3, selMp3s = nil, playlist_api.getPlaylist()
  if config.texifySelMp3s then
    local selMp3
    selMp3, selMp3s = playlist_gui.getSelection()
  end
  if not selMp3s and config.downloadWhichMp3s == 'Selected' then
    iup.Message('Warning', 'No songs are selected!')
    return
  end

  local fileName, ext = os.getFileWithoutExt(playlist_api.getPlaylistName())

  getPdfGenerator().generateSongbook(selMp3s, fileName)
  return iup.DEFAULT
end

local function rebuildCache()
  print('Rebuilding cache...')
  -- This will get nr of items already in cache, so progress dialog will only show progress
  -- of removal of unexisting items in cache
  local item = 1
  local nrItems = cache.getNrItems()
  local progressDialog, updateLabel, progressBar = progress_dialog.getDialog("Rebuilding cache...", "Removed from cache:")
  progressBar.max = nrItems
  progressDialog:show()
  cache.buildCache(
    function(itemName)
      updateLabel.title = itemName or updateLabel.title
      progressBar.value = item
      item = item + 1
    end)
  iup.Destroy(progressDialog)
  updateGui('playlist', 'searchsites', 'lyrics')
end

function settingsButton:action()
  local miktexDirModified, audioPlayerLocationModified
  local function param_action(dialog, param_index)
    if (param_index == 0) then
      miktexDirModified = true
    elseif param_index == 1 then
      audioPlayerLocationModified = true
    elseif (param_index == -2) then
      dialog.size = "500x150"
      setDialogIcon(dialog)
    end
    return 1
  end
  local ret, miktexDir, audioPlayerLocation, rescanCache, removeUnusedLyrics, removeHtml =
  iup.GetParam("Settings", param_action,
                  "Miktex location: %f[DIR|*.*|" .. config.miktexDir .. "|NO|NO]\n" ..
                  "Audio player location: %f[FILE|*.exe|" .. config.audioPlayerLocation .. "|NO|NO]\n" ..
                  "Playlist track match: %s\n" ..
                  "Rebuild cache: %b\n" ..
                  "Remove unused txt files from cache: %b\n" ..
                  "Remove html files from cache: %b\n",
                  config.miktexDir, config.audioPlayerLocation, config.artistTitleMatch, 0, 0, 0)

  if ret == 0 or not ret then return end -- dialog was cancelled

  if miktexDir == '' then
    iup.Message('Error', 'Miktex location cannot be empty!')
  else
    miktexDir = miktexDir:gsub('\n', '')
    if miktexDirModified and os.checkIfFileExists(miktex.getMiktexDir(miktexDir), 'texify.exe', ' Go to http://www.miktex.org to obtain Miktex and make sure the Miktex location is set correctly in the Settings Dialog') then
      config.miktexDir = miktexDir
    end
    if audioPlayerLocationModified then
      config.audioPlayerLocation = audioPlayerLocation
    end
    if rescanCache == 1 then
      rebuildCache()
    end
    if removeUnusedLyrics == 1 then
      local ret = iup.Alarm('Warning',  'Are you sure you want to remove unused txt files from cache?\n' ..
                                        'Make sure you selected for each song the right lyrics!\n' ..
                                        'Note that a search site is selected by right clicking on the\n' ..
                                        'site and selecting "Select these lyrics for songbook".\n' ..
                                        'Otherwise, the search site ranked most highly will be\n' ..
                                        'used to deliver the lyrics.', 'Yes', 'No', 'Cancel')
      if ret == 1 then
        local item = 1
        local nrItems = cache.getNrItems()
        local progressDialog, updateLabel, progressBar = progress_dialog.getDialog("Removing unused items...", "Removed file from cache:", nil, nil, closeCallback)
        progressBar.max = nrItems
        progressDialog:show()

        cache.removeUnusedLyrics(function(itemName)
          updateLabel.title = itemName
          progressBar.value = item
          item = item + 1
        end)
        iup.Destroy(progressDialog)
        updateGui('playlist', 'searchsites', 'lyrics')
      end
    end
    if removeHtml == 1 then
      os.removeFileType(LYRICS_DIR, 'html')
      rebuildCache()
      updateGui('playlist', 'searchsites', 'lyrics')
    end
  end
end

widget = iup.hbox
      {
        gap="5",
        expand="horizontal",

        newPlaylistButton,
        addToPlaylistButton,
        openPlaylistButton,
        savePlaylistButton,
        sortButton,
        removeDoublesButton,
        downloadLyricsButton,
        createSongbookButton,
        iup.label{title = "", expand = "HORIZONTAL"}, -- Tried to do this with iup.fill but this doesn't work...
        settingsButton,
      }

function update(playlistModified)
  local tracks = playlist_api.getPlaylist()
  local active = (tracks and #tracks > 0) and 'YES' or 'NO'
  sortButton.active = active
  removeDoublesButton.active = active
  downloadLyricsButton.active = active
  createSongbookButton.active = active
  savePlaylistButton.active = (playlistModified and tracks and #tracks > 0) and 'YES' or 'NO'
end
