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

function TestMisc:testGetDrive()
  local drive = os.getDrive([[c:\temp]])
  assertEquals(drive, 'c:')
  drive = os.getDrive([[C:\temp]])
  assertEquals(drive, 'C:')
end

function TestMisc:testGetNoDrive()
  local drive = os.getDrive([[\temp]])
  assert(not drive)
  drive = os.getDrive([[test.txt]])
  assert(not drive)
end
