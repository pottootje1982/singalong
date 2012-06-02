
require 'luaunit'
require 'ext_string'

TestStringExt = {}

function TestStringExt:testIsStringEmptyOrSpace()
  assert(string.isStringEmptyOrSpace([[


  ]]))
  assert(not string.isStringEmptyOrSpace([[
asdfdd

  ]]))
    assert(string.isStringEmptyOrSpace([[               ]]))
end
