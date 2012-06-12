module('iup_getparam', package.seeall)

assert(iup)

-- overwrite iup.GetParam to fix bug that when dialog is confirmed with enter
-- the dialog will be closed, but if a file selector edit field was active,
-- the string will be spit with a newline

local getParamOld = iup.GetParam

iup.GetParam = function(title, callback, ...)
  local customCallback = function(dialog, paramIndex)
    if paramIndex >= 0 then
      local value = iup.GetParamParam(dialog, paramIndex).value
      if type(value) == 'string' and value:find('\n') then
        iup.GetParamParam(dialog, paramIndex).value = value:gsub('\n', '')
      end
    end
    if callback then return callback(dialog, paramIndex) end
    return 1
  end
  return getParamOld(title, customCallback, ...)
end
