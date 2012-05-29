require 'luaunit'
require 'spotify_playlist'

TestSpotifyPlaylist = {}

local samplePlaylist =
[[http://open.spotify.com/track/4WToGRH29Gp1gMDU67OLtZ]]

local longSamplePlaylist =
[[http://open.spotify.com/local///1793+George+Harrison+-+Give+me+love/217]]


function TestSpotifyPlaylist:testParseSpotifyPlaylist()
  local songs = spotify_playlist.parseSpotifyPlaylist(samplePlaylist)
  assert(songs)
  assertEquals(songs[1].artist, 'Fernando Goin')
  assertEquals(songs[1].title, 'Make You Feel My Love')
end

--[[[
function TestSpotifyPlaylist:testLongSamplePlaylist()
  local songs = spotify_playlist.parseSpotifyPlaylist(longSamplePlaylist)
  table.print(songs)
  assert(songs)
  assertEquals(songs[1].artist, 'Fernando Goin')
  assertEquals(songs[1].title, 'Make You Feel My Love')
end

 TestSpotifyPlaylist:testLongSamplePlaylist()
--]]
