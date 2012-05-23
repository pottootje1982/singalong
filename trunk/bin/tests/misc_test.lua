require 'misc'

TestMisc = {}

function TestMisc:testTableFilter()
  local res = table.filter({2, 4, 5, 6}, function(index, val) return val < 5 end)
  assertEquals(#res, 2)
  assertEquals(res[1], 2)
  assertEquals(res[2], 4)
end
