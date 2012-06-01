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
