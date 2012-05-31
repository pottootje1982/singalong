require 'misc'
require 'luaunit'
require 'playlist_api'
require 'playlist_helpers'

TestPlaylistApi = {}

function TestPlaylistApi:testExtractArtistTitle()
  fileStr = [[10CC - Dreadlock Holiday]]
  local artist, title = playlist_helpers.extractArtistTitle(fileStr)
  assertEquals(artist, '10CC')
  assertEquals(title, 'Dreadlock Holiday')
end

function TestPlaylistApi:testGatherMp3Info()
  local mp3s = playlist_api.gatherMp3Info(F(system.getExecutablePath(), 'verukkelijke 715 zang.m3u'))
  assertEquals(#mp3s, 73)
end

function TestPlaylistApi:testGatherMp3InfoFromFiles()
  local tracks = playlist_api.gatherMp3InfoFromFiles({[[beatles - hey jude.mp3]], [[neil young - unknown legend.mp3]]})
  assertEquals(#tracks, 2)
  assertEquals(tracks[1].artist, 'beatles')
  assertEquals(tracks[1].title, 'hey jude')
  assertEquals(tracks[2].artist, 'neil young')
  assertEquals(tracks[2].title, 'unknown legend')
end

function TestPlaylistApi:testGatherMp3InfoFromPaths()
  local tracks = playlist_api.gatherMp3InfoFromFiles({[[c:\temp\beatles - hey jude.mp3]], [[c:\temp\neil young - unknown legend.mp3]]})
  assertEquals(#tracks, 2)
  assertEquals(tracks[1].artist, 'beatles')
  assertEquals(tracks[1].title, 'hey jude')
  assertEquals(tracks[2].artist, 'neil young')
  assertEquals(tracks[2].title, 'unknown legend')
end

