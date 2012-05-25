require 'spotify_playlist'

TestSpotifyPlaylist = {}

local samplePlaylist =
[[http://open.spotify.com/track/4WToGRH29Gp1gMDU67OLtZ]]

local longSamplePlaylist =
[[http://open.spotify.com/track/4WToGRH29Gp1gMDU67OLtZ
http://open.spotify.com/track/69gZzofJUJ8srHwuDqzR3l
http://open.spotify.com/track/53Nu9T4OtqPZieukvVOvOh
http://open.spotify.com/local/Herman+Emmink/78+Hollandse+Hits/Tulpen+Uit+Amsterdam/147
http://open.spotify.com/local/Zangeres+Zonder+Naam/78+Hollandse+Hits/Mexico/231
http://open.spotify.com/local/Lenny+Kuhr/78+Hollandse+Hits/De+Troubadour/180
http://open.spotify.com/local/Jenny+Arean+%26+Frans+Halsema/78+Hollandse+Hits/Vluchten+Kan+Niet+Meer/219
http://open.spotify.com/local/Fouryo%27s/78+Hollandse+Hits/Zeg+Niet+Nee/116
http://open.spotify.com/local/Simone+Kleinsma+%26+Robert+Long/78+Hollandse+Hits/Vanmorgen+Vloog+Ze+Nog/281
http://open.spotify.com/track/0sOwSMwz1ZfzTGI8s13cO6
http://open.spotify.com/track/3NW1YMA8kfNVTzGJCGBS8m
]]


function TestSpotifyPlaylist:testParseSpotifyPlaylist()
  local songs = spotify_playlist.parseSpotifyPlaylist(samplePlaylist)
  assert(songs)
  assertEquals(songs[1].artist, 'Fernando Goin')
  assertEquals(songs[1].title, 'Make You Feel My Love')
end

