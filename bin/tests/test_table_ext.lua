require 'misc'
require 'luaunit'

TestTableExt = {}

-- TODO: fix table.unmarshal so that it can load empty tables
function TestTableExt:testSaveTable()
  table.saveToFile('test.sing', {})
  local res = table.loadFromFile('test.sing')
  --assert(res)
end

TestTableExt:testSaveTable()
