require 'luaunit'
require 'misc'

TestMisc = {}

function TestMisc:testTableFilter()
  local res = table.filter({2, 4, 5, 6}, function(index, val) return val < 5 end)
  assertEquals(#res, 2)
  assertEquals(res[1], 2)
  assertEquals(res[2], 4)
end

function TestMisc:testTableMerge()
  local res = table.imerge({1, 2, 3, 4}, {11, 12, 13, 14})
  assert(table.equals(res, {1, 2, 3, 4, 11, 12, 13, 14}))
end

function TestMisc:testTableMergeAt()
  local res = table.imerge({1, 2, 3, 4}, {11, 12, 13, 14}, 3)
  table.print(res)
  assert(table.equals(res, {1, 2, 11, 12, 13, 14, 3, 4}))
end
