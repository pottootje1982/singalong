require 'luaunit'
require 'misc'

TestMisc = {}

function TestMisc:testGetPath()
  local path, file = os.getPath([[c:\temp\test.txt]])
  assertEquals(path, [[c:\temp]])
  assertEquals(file, [[test.txt]])
  path, file = os.getPath([[d:\temp\]])
  assertEquals(path, [[d:\temp]])
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

function TestMisc:testMakeAbs()
  local absPath = os.makeAbsolute([[\music\test.mp3]], [[d:\temp]])
  assertEquals(absPath, [[d:\music\test.mp3]])
  local fn = [[c:\music\test.mp3]]
  assert(os.getDrive(fn))
  absPath = os.makeAbsolute(fn, [[d:\temp]])
  assertEquals(absPath, [[c:\music\test.mp3]])
  absPath = os.makeAbsolute([[test.mp3]], [[d:\temp\]])
  assertEquals(absPath, [[d:\temp\test.mp3]])
end

function TestMisc:testMakeAbs2()
  local track = [[\Users\Wouter\Music\#Mp3 DVD 9\Arrow Rock 500\101 (2000). Beatles - A day in the life.mp3]]
  local plPath = [[D:\Users\Wouter\Documents\My Dropbox\playlists\The Beatles.sing]]
  print(os.makeAbsolute(track, plPath))
end

