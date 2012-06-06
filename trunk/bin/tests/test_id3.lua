require 'misc'
require 'id3'
require 'luaunit'

TestId3 = {}

-- TODO: fix table.unmarshal so that it can load empty tables
function TestId3:testReadAlbum()
  table.print(id3.readtags('song.mp3'))
end
