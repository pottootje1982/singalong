module('downloader', package.seeall)

require 'socketinterface'
require 'playlist_gui'

local function determineWaitInterval()
  if config.wait then
    local randVal = config.maxWait==config.minWait and 0 or math.random(config.maxWait-config.minWait)
    return randVal + config.minWait
  end
end

-- Download routine func
local function routineFunc(ds, selMp3s, selSites)
  return function()
    for i, mp3 in ipairs(selMp3s) do
      ds.currMp3Index = i
      ds.currMp3 = mp3

      local lastMp3 = i == #selMp3s
      if not (lastMp3 and ds.numSites == 1) then
        ds.totalWaitTime = determineWaitInterval()
      else
        ds.totalWaitTime = nil
      end

      -- arguments customArtist and customTitle are non-nil if you want to specify custom query
      query.downloadLyrics(mp3, selSites, ds.totalWaitTime, lastMp3)

      -- not that i is not always the correct index, as we're dealing with selMp3s
      -- which might be a subset of playlist tracks
      playlist_gui.widget:updateItem(nil, mp3)
    end
  end
end

local function endFunc(progressDialog)
  return function()
    iup.Destroy(progressDialog)
    updateGui('playlist', 'searchsites', 'lyrics')
  end
end

local function errorCallback(errorMessage)
  if errorMessage:find(query.GOOGLE_BAN) then
    iup.Message('Warning', 'Google banned you, try increasing the wait time!\nAfter you click OK, you will be redirected to a page were you have\nto solve the CAPTCHA assignment.')
    showCaptchaAssignment()
    return true
  end
end

-- Function called when routine func calls coroutine.yield()
local function resumeFunc(ds)
  return function(siteIndex, waitingPerSite)
    if type(siteIndex) == 'number' then
      local siteName = waitingPerSite
      ds.currSiteIndex = siteIndex
      ds.updateLabel.title = string.format('%s - %s (%s)' , ds.currMp3.artist, ds.currMp3.title, siteName)
      ds.downloadProgressbar.value = (ds.currMp3Index - 1) * ds.numSites + ds.currSiteIndex - 1
    elseif waitingPerSite then
      local waitTime = ds.totalWaitTime or ds.avgWaitTime
      ds.downloadProgressbar.value = (ds.currMp3Index - 1) * ds.numSites + ds.currSiteIndex - 1 + waitingPerSite / waitTime
    end
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

  if not require 'download_dialog'() then return end

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
  --progressDialog.parentdialog = mainDialog

  local ds =
  {
    currMp3Index = nil,
    currMp3 = nil,
    currSiteIndex = nil,
    totalWaitTime = nil,
    numSites = numSites,
    avgWaitTime = avgWaitTime,
    downloadProgressbar = downloadProgressbar,
    updateLabel = updateLabel
  }

  downloadCo = app.addCo( routineFunc(ds, selMp3s, selSites),
                          resumeFunc(ds),
                          endFunc(progressDialog), errorCallback)

  -- TODO: cannot make it popup @ parent. The statement
  -- progressDialog:popup(iup.CENTERPARENT, iup.CENTERPARENT)
  -- causes crashes when downloadLyrics() is invoked twice
  progressDialog:popup()
end

