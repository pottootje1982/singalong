local args = {...}

package.path = package.path .. ';tests\\?.lua'

require 'misc'
require 'luaunit'
require 'lfs'

for file in lfs.dir('tests') do
  if file:match('lua$') and not file:match('run_tests') then
    local fileWithoutExt = file:match('(.*)%.lua$')
    print(fileWithoutExt)
    require(fileWithoutExt)
  end
end

LuaUnit:run()
