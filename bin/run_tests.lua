local args = {...}

local executablePath = system.getExecutablePath()
local testPath = executablePath .. 'tests'
package.path = package.path .. ';' .. testPath .. '\\?.lua'

require 'misc'
require 'luaunit'
require 'lfs'

for file in lfs.dir(testPath) do
  if file:match('lua$') and not file:match('run_tests') then
    local fileWithoutExt = file:match('(.*)%.lua$')
    require(fileWithoutExt)
  end
end

luaunit.PRINT_FUNCTION_LOCATION = false
luaunit.run()

if args[1] == 'pause' then
  debug.debug()
end
