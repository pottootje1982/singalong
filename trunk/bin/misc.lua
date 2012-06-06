require 'lfs'
require 'ext_os'
require 'ext_table'
require 'ext_string'
require 'ext_coroutine'

-- constitutes a path from strings
F = function(...)
  return table.concat(arg, [[\]])
end

_ = function(str)
    -- ^     $        (       )       %      .       [      ]         *        +       -       ?
    return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", '%%%1')
end

getPdfGenerator = function()
  -- pdfGenerator can be 'Singalong pdf' hence the gsub
  return require(config.pdfGenerator:gsub(' ', ''))
end

getFontColor = function(str)
  local r, g, b = str:match('(%d+) (%d+) (%d+)')
  return tonumber(r)/255,tonumber(g)/255,tonumber(b)/255
end

getSize = function(str)
  local w, h = str:match('(%d+)x(%d+)')
  return tonumber(w), tonumber(h)
end

function setDialogIcon(dialog)
  system.setIcon(HINSTANCE, dialog.title)
end

local function invokeOnGui(func, ...)
  for i, v in ipairs(arg) do
    local args = {}
    if type(arg[i+1]) == 'table' then
      args = arg[i+1]
    end
    if type(v) == 'string' then
      require(v .. '_gui')[func](unpack(args))
    end
  end
end

function updateGui(...)
  invokeOnGui('update', ...)
end

function destroyGui(...)
  invokeOnGui('destroy', ...)
end

function iupParamCallback(dialog, paramIndex)
  if paramIndex == -2 then -- -2 = after the dialog is mapped and just before it is shown;
    setDialogIcon(dialog)
  end
end

