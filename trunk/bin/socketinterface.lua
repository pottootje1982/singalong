module('socketinterface', package.seeall)

require 'misc'
require 'load_config'()

EXECUTABLE_PATH = EXECUTABLE_PATH or [[.\]]

package.path = package.path .. ';' .. F(EXECUTABLE_PATH, [[socket\?.lua]])
require('socket.socket')
local http = require("socket.http")

function request(url, fn)
  local proxy = config.proxy
  local succ, httpErrorCode, content = http.request{url = url,
    sink = fn and ltn12.sink.file(io.open(fn, 'w')),
    proxy = proxy,
  }
  if httpErrorCode ~= 200 then -- 200 means OK
    print(string.format('Executing url "%s" returned following http error: %s', tostring(url), tostring(httpErrorCode)))
    --table.print(content)
    return httpErrorCode
  end
end

function open(url)
  local tempName = os.tmpname():gsub('\\', '') .. '.html'
  local fn = F(LOCALAPPDATADIR, tempName)
  request(url, fn)
  local content = os.read(fn)
  if not config.keepTempFile then
    os.remove(fn)
  end
  return content
end

-- The following will only be executed if called from task.create
if arg and arg[1] and arg[2] then
  os.writeTo('t.txt', arg[1] .. arg[2])
  local succ, mess = pcall(function()
    request(arg[1], arg[2])
  end)
  if not succ then
    os.writeTo('err.txt', mess)
  end
end
