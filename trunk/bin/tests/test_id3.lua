require 'misc'
require 'id3'
require 'test_setup'
require 'luaunit'

TestId3 = {}

-- The first file has unicode ID3 V2 tags, which should be turned into regular strings with id3.convertUnicode()
local fn1 = testDataDir [[06. Roll Over Beethoven.mp3]]
local fn2 = testDataDir [[01. Come Together.mp3]]

-- TODO: fix table.unmarshal so that it can load empty tables
function TestId3:testReadAlbum()
  local tags = id3.readtags(testDataDir('song.mp3'))
  assertEquals(tags.album, 'None')
end

function TestId3:testReadAlbum2()
  local tags = id3.readtags(fn1)
  assertEquals(tags.title, 'Roll Over Beethoven')
  assertEquals(tags.artist, 'The Beatles')
  tags = id3.readtags(fn2)
  assertEquals(tags.title, 'Come Together')
  assertEquals(tags.artist, 'The Beatles')
end


TestId3:testReadAlbum2()
