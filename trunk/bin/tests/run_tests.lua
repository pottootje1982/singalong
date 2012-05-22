require 'misc'

local args = {...}

local testDir = '.'
if args[1] then
  testDir = args[1]
  package.path = package.path .. ';' .. testDir .. '\\?.lua'
end

package.path = package.path .. ';..\\?.lua'

require 'luaunit'
require 'lfs'

---[[
for file in lfs.dir(testDir) do
  if file:match('lua$') and not file:match('run_tests') then
    local fileWithoutExt = file:match('(.*)%.lua$')
    print(fileWithoutExt)
    require(fileWithoutExt)
  end
end 

LuaUnit:run()
--]]
