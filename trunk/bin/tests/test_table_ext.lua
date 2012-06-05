require 'misc'
require 'luaunit'
require 'title_bar_gui'

TestTableExt = {}

-- TODO: fix table.unmarshal so that it can load empty tables
function TestTableExt:testSaveTable()
  table.saveToFile('test.sing', {})
  local res = table.loadFromFile('test.sing')
  --assert(res)
end

function TestTableExt:testTableFind()
  assertEquals(table.ifind({1,4,6,7}, 6), 3)
  assertEquals(table.ifind({1,4,6,7}, function(i, elem) return elem > 5 end), 3)
  assertEquals(table.ifind({1,4,6,7}, function(i, elem) return elem > 8 end), nil)

  assertEquals(table.ifind({1,4,6,7}, function(i, elem) return elem < 4 end, 1), 1)
  assertEquals(table.ifind({1,4,6,7}, function(i, elem) return elem < 4 end, 3), nil)
  assertEquals(table.ifind({1,4,6,7}, function(i, elem) return elem <= 6 end, 3), 3)


  assertEquals(table.find({a=3, b=4, c=7}, 3), 'a')
  assertEquals(table.find({a=3, b=4, c=7}, function(key, elem) return elem > 5 end), 'c')
  assertEquals(table.find({a=3, b=4, c=7}, function(key, elem) return elem > 8 end), nil)
end

function TestTableExt:testTableRemoveDoubles()
  local unique = table.removeDoubles({1,3,4,4,5,5,6})
  assert(table.equals(unique, {1,3,4,5,6}))

  local tableDoubles = {
    {artist = 'beatles', title = 'hey jude'},
    {artist = 'beatles', title = 'hey jude'},
    {artist = 'neil young', title = 'unknown legend'},
    {artist = 'beatles', title = 'hey jude'},
    {artist = 'beatles', title = 'hey jude'},
    {artist = 'neil young', title = 'king'}
  }
  unique = table.removeDoubles(tableDoubles, title_bar_gui.compareTracks)
  assert(table.equals(unique,
  {
    {artist = 'beatles', title = 'hey jude'},
    {artist = 'neil young', title = 'unknown legend'},
    {artist = 'neil young', title = 'king'}
  }
    ))
end

TestTableExt:testTableRemoveDoubles()
