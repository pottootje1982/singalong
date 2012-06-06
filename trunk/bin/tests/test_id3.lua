require 'misc'
require 'id3'
require 'test_setup'
require 'luaunit'

TestId3 = {}

-- TODO: fix table.unmarshal so that it can load empty tables
function TestId3:testReadAlbum()
  local tags = id3.readtags(testDataDir('song.mp3'))
  assertEquals(tags.album, 'None')
end
