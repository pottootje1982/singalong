module('downloader', package.seeall)

require 'socketinterface'
require 'playlist_gui'

local function determineWaitInterval()
  if config.wait then
    local randVal = config.maxWait==config.minWait and 0 or math.random(config.maxWait-config.minWait)
    return randVal + config.minWait
  end
end

function downloadLyrics(parentDialogTitle)
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

  local numSites = #selSites
  local numMp3s = #selMp3s
  local avgWaitTime = config.minWait + config.maxWait / 2

  local downloadCo
  local closeCallback = function()
    app.removeCo(downloadCo)
  end
  local progressDialog, updateLabel, downloadProgressbar = progress_dialog.getDialog("Downloading lyrics...", "Downloading lyrics:", closeCallback, "Stop downloading", closeCallback)

  downloadProgressbar.max = numMp3s * numSites
  progressDialog.parentdialog = parentDialogTitle

  progressDialog:show()

  local currMp3Index = nil
  local currMp3 = nil
  local currSiteIndex = nil
  local totalWaitTime = nil
  local lastMp3 = nil

  -- Download routine func
  local function routineFunc()
    for i, mp3 in ipairs(selMp3s) do
      currMp3Index = i
      currMp3 = mp3

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
  local function resumeFunc(siteIndex, waitingPerSite)
    if type(siteIndex) == 'number' then
      local siteName = waitingPerSite
      currSiteIndex = siteIndex
      updateLabel.title = string.format('%s - %s (%s)' , currMp3.artist, currMp3.title, siteName)
      downloadProgressbar.value = (currMp3Index - 1) * numSites + currSiteIndex - 1
    elseif waitingPerSite then
      local waitTime = totalWaitTime or avgWaitTime
      downloadProgressbar.value = (currMp3Index - 1) * numSites + currSiteIndex - 1 + waitingPerSite / waitTime
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

