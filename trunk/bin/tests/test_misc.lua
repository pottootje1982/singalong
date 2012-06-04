require 'luaunit'
require 'misc'

TestMisc = {}

function TestMisc:testGetPath()
  local path, file = os.getPath([[c:\temp\test.txt]])
  assertEquals(path, [[c:\temp]])
  assertEquals(file, [[test.txt]])
end

function TestMisc:testGetNoPath()
  local path, file = os.getPath([[test.txt]])
  assert(not path)
  assertEquals(file, [[test.txt]])
end

function TestMisc:testGetNoFile()
  local path, file = os.getPath([[c:\temp\]])
  assert(not file)
  assertEquals(path, [[c:\temp]])
end

TestMisc:testGetNoFile()
