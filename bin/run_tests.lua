local args = {...}

require 'test_setup'
require 'luaunit'

for file in lfs.dir(TEST_PATH) do
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
