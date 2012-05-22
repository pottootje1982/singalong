require 'misc'

TestMisc = {}

function TestMisc:testTableFilter()
  local res = table.filter({2, 4, 5, 6}, function(index, val) return val < 5 end)
  assert(#res == 2, 'Result is ' .. #res)
  assert(res[1] == 2)
  assert(res[2] == 4)
end