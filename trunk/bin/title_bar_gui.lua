module('title_bar_gui', package.seeall)

require 'misc'
require 'playlist_api'
require 'progress_dialog'
require 'icon'
require 'add_icon'

local newPlaylistButton = iup.button{title="", image = 'IUP_FileNew', tip="New playlist (ctr-n)"}
local addToPlaylistButton = iup.button{title="", image = addIcon, tip="Add to current playlist"}
local openPlaylistButton = iup.button{title="", image = 'IUP_FileOpen', tip="Open playlist (ctr-o)"}
local savePlaylistButton = iup.button{title="", image = 'IUP_FileSave', tip="Save playlist (ctr-s)"}
local downloadLyricsButton = iup.button{tip="Download lyrics (ctr-d)", image=downloadIcon, active = 'NO'}
local sortButton = iup.button{tip="Sort playlist", image='IUP_ToolsSortAscend', active = 'NO'}
local createSongbookButton = iup.button{tip="Create songbook (ctr-b)", image = 'IUP_FileText', active = 'NO'}
local settingsButton = iup.button{tip="Settings", image = 'IUP_ToolsSettings', alignment='ARIGHT'}
local AVG_REQUEST_TIME = 0.7

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
end

function sortButton:action()
  local tracks = playlist_api.getPlaylist()
  sortTracks(tracks)
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
    local ret, captchaAns = iup.GetParam("Enter Captcha string", iupParamCallback,
                    "Enter characters from image: %s\n", '')

    if ret == 0 or not ret then return end -- dialog was cancelled

    url = baseUrl ..'/Captcha?continue=' .. url
    local captchUrl = string.format('%s&id=%s&captcha=%s&submit=Submit', url, captchaId, captchaAns)
    print('Trying to resolve CAPTCHA assignment with url:', captchUrl)
    socketinterface.request(captchUrl, 'resol.html')
  end
end

local function determineWaitInterval()
  if config.wait then
    local randVal = config.maxWait==config.minWait and 0 or math.random(config.maxWait-config.minWait)
    return randVal + config.minWait
  end
end

function downloadLyrics()
  -- First check if there's internet access
  local err = socketinterface.request('http://www.google.com/search?q=test')
  if err then
    iup.Message('Warning', "No internet connection..." .. err)
    return
  end

  local selMp3, selMp3s = playlist_gui.getSelection()

  local function callback(dialog, paramIndex, bla)
    if paramIndex == -2 then
      setDialogIcon(dialog)
    elseif paramIndex == 4 or paramIndex == 5 then -- make sure min won't be higher than max
      local minParam = iup.GetParamParam(dialog, 4)
      local maxParam = iup.GetParamParam(dialog, 5)
      local otherParam = iup.GetParamParam(dialog, paramIndex == 4 and 5 or 4)
      local otherControl = iup.GetAttribute(otherParam, "CONTROL")
      if tonumber(minParam.value) >= tonumber(maxParam.value) then
        -- in principle the following should work. However, iup.GetAttribute(otherParam, "CONTROL")
        -- return the string 'IUP', due to some bug. Probably uncomment code, after an iup update
        --iup.SetAttribute(otherParam, 'VALUE', 99)
        --iup.SetAttribute(otherControl, 'VALUE', otherParam.value)
      end
      iup.UpdateChildren(dialog)
    end
    return 1
  end

  local downloadWhichMp3s = table.find(whichSelection, config.downloadWhichMp3s)
  local function num(bool) return bool and 1 or 0 end
  local ret, stopAfterFirstHit, downloadWhichMp3s, downloadSelSites, w, minWait, maxWait =
  iup.GetParam("Download lyrics", callback,
                  "Stop downloading after first hit: %b\n"..
                  "Download which songs: %l" .. table.zeroConcat(whichSelection, '|') .. "\n" ..
                  "Download from selected sites only: %b\n" ..
                  "%t\n" ..
                  "Wait between downloads: %b\n"..
                  "Minimum wait time between downloads: %i[0,100,1]\n"..
                  "Maximum wait time between downloads: %i[0,100,1]\n",

                  num(config.stopAfterFirstHit), downloadWhichMp3s, num(config.downloadSelSites),
                  num(config.wait), config.minWait, config.maxWait)

  if ret == 0 or not ret then return end -- dialog was cancelled
  config.wait = w == 1
  config.minWait = minWait
  config.maxWait = maxWait
  config.stopAfterFirstHit = stopAfterFirstHit == 1
  config.downloadWhichMp3s = whichSelection[downloadWhichMp3s]
  config.downloadSelSites = downloadSelSites == 1

  local allTracks = playlist_api.getPlaylist()
  if config.downloadWhichMp3s == 'All' then
    selMp3s = allTracks
  elseif config.downloadWhichMp3s == 'Selection' then
  elseif config.downloadWhichMp3s == 'Unfound' then
    selMp3s = table.ifilter(allTracks, function(i,track)
      return not cache.IsTxtInCache(track)
    end)
  end

  if not (config.minWait <= config.maxWait) then
    iup.Message('Warning', 'Minimum wait value should be smaller than maximum!')
    return
  end
  if not selMp3s or table.isEmpty(selMp3s) then
    if config.downloadWhichMp3s == 'Selected' then
      iup.Message('Warning', 'No tracks are selected!')
    elseif config.downloadWhichMp3s == 'Unfound' then
      iup.Message('Warning', 'There are no unfound songs!')
    end
    return
  end

  local selSite, selSites = searchsites_gui.widget:getSelection(search_sites)
  selSites = config.downloadSelSites and selSites or search_sites

  numSites = #selSites
  local numMp3s = #selMp3s
  local avgWaitTime = config.minWait + config.maxWait / 2

  local downloadCo
  local closeCallback = function()
    app.removeCo(downloadCo)
  end
  local progressDialog, updateLabel, downloadProgressbar = progress_dialog.getDialog("Downloading lyrics...", "Downloading lyrics:", closeCallback, "Stop downloading", closeCallback)

  downloadProgressbar.max = numSites > 1 and numMp3s or ((numMp3s - 1) + AVG_REQUEST_TIME/avgWaitTime)
  progressDialog.parentdialog = mainDialog.title

  progressDialog:show()

  local currMp3Index = nil
  local currMp3 = nil
  local totalWaitTime = nil
  local lastMp3 = nil
  local cumWaitTime = nil
  local beginTime = os.clock()
  local res

  -- Download routine func
  local function routineFunc()
    for i, mp3 in ipairs(selMp3s) do
      currMp3Index = i
      currMp3 = mp3
      cumWaitTime = 0
      beginTime = os.clock()

      lastMp3 = i == #selMp3s
      if not (lastMp3 and numSites == 1) then
        totalWaitTime = determineWaitInterval()
      else
        totalWaitTime = nil
      end

      -- arguments customArtist and customTitle are non-nil if you want to specify custom query
      query.downloadLyrics(mp3, selSites, totalWaitTime, lastMp3)

      -- not that i is not always the correct index, as we're dealing with selMp3s
      -- which might be a subset of playlist tracks
      playlist_gui.widget:updateItem(nil, mp3)
    end
  end
  -- Function called when routine func calls coroutine.yield()
  local function resumeFunc(resume, res)
    -- wait time can be longer than expected due to wait for socketinterface.request to finish
    --print(cumWaitTime, totalWaitTime, lastWaitTime, res)
    local nrWaits = lastMp3 and (#selSites - 1) or #selSites
    local maxProgress = math.min(os.clock() - beginTime, (totalWaitTime or avgWaitTime) * nrWaits)
    downloadProgressbar.value = currMp3Index - 1 + maxProgress / ((totalWaitTime or avgWaitTime) * nrWaits)
    if res and type(res) == 'string' then
      updateLabel.title = string.format('%s - %s (%s)' , currMp3.artist, currMp3.title, res)
    end
  end
  local function endFunc()
    iup.Destroy(progressDialog)
    updateGui('playlist', 'searchsites', 'lyrics')
  end
  local function errorCallback(errorMessage)
    if errorMessage:find(query.GOOGLE_BAN) then
      iup.Message('Warning', 'Google banned you, try increasing the wait time!\nAfter you click OK, you will be redirected to a page were you have\nto solve the CAPTCHA assignment.')
      showCaptchaAssignment()
      return true
    end
  end
  downloadCo = app.addCo(routineFunc, resumeFunc, endFunc, errorCallback)
end

function downloadLyricsButton:action()
  downloadLyrics()
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
    iup.GetParam("Create songbook", iupParamCallback,
                      "PDF generator: %l"  .. table.zeroConcat(pdfGenerators, '|') .. "\n"..
                      "Use selected songs only: %b\n" ..
                      "%t\n" ..
                      "Font size: %l" .. table.zeroConcat(fontSizes, '|') .. "\n" ..
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
  local miktexDirModified
  local function param_action(dialog, param_index)
    if (param_index == 0) then
      miktexDirModified = true
    elseif (param_index == -2) then
      setDialogIcon(dialog)
    end
    return 1
  end
  local ret, miktexDir, rescanCache, removeUnusedLyrics, removeHtml =
  iup.GetParam("Settings", param_action,
                  "Miktex location: %f[DIR|*.*|" .. config.miktexDir .. "|NO|NO]\n" ..
                  "Rebuild cache: %b\n" ..
                  "Remove unused txt files from cache: %b\n" ..
                  "Remove html files from cache: %b\n",
                  config.miktexDir, 0, 0, 0)

  if ret == 0 or not ret then return end -- dialog was cancelled

  if miktexDir == '' then
    iup.Message('Error', 'Miktex location cannot be empty!')
  else
    miktexDir = miktexDir:gsub('\n', '')
    if miktexDirModified and os.checkIfFileExists(miktex.getMiktexDir(miktexDir), 'texify.exe', ' Go to http://www.miktex.org to obtain Miktex and make sure the Miktex location is set correctly in the Settings Dialog') then
      config.miktexDir = miktexDir
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
        downloadLyricsButton,
        createSongbookButton,
        iup.label{title = "", expand = "HORIZONTAL"}, -- Tried to do this with iup.fill but this doesn't work...
        settingsButton,
      }

function update(playlistModified)
  local tracks = playlist_api.getPlaylist()
  local active = (tracks and #tracks > 0) and 'YES' or 'NO'
  lyrics_gui.saveLyricsButton.active = active
  sortButton.active = active
  downloadLyricsButton.active = active
  createSongbookButton.active = active
  savePlaylistButton.active = (playlistModified and tracks and #tracks > 0) and 'YES' or 'NO'
end
