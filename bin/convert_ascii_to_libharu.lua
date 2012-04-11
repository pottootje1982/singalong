require 'misc'
require 'replace'

local html_ascii_to_libharu = 
{
  '(\\\\%s*%c)', '\n', -- if this replacement is not done first we 
                       -- will generate too many newlines, because \\ becomes
                       -- a newline + the already present newlines in the txt file
  '(\\\\)', '\n',
}

return 
function(str)
  return replace(str, html_ascii_to_libharu)
end