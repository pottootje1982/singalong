
module('download_dialog', package.seeall)

require 'constants'

return function()
  local function callback(dialog, paramIndex)
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

  if ret == 0 or not ret then return false end -- dialog was cancelled
  config.wait = w == 1
  config.minWait = minWait
  config.maxWait = maxWait
  config.stopAfterFirstHit = stopAfterFirstHit == 1
  config.downloadWhichMp3s = whichSelection[downloadWhichMp3s]
  config.downloadSelSites = downloadSelSites == 1
  return true
end
