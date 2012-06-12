require 'luaunit'
require 'query'
require 'playlist_gui'

TestPlaylistGui = {}

function TestPlaylistGui:testQueryGoogle()
  playlist_api.setPlaylist({{artist='beatles', title='hey jude'}})
	playlist_gui.widget:modifySelection(1, 1, true)
  local content, fn = playlist_gui.widget:queryGoogle(false)
  assert(content:match(playlist_gui.YOUTUBE_MATCH):match('http://www.youtube.com'))
end

function TestPlaylistGui:testReplace()
  local html = [[<a href="/url?q=http://www.lyricsfreak.com/n/neil%2Byoung/unknown%2Blegend_20099115.html&amp;sa=U&amp;ei=gfPWT8CFN8XPhAfYlPDcAw&amp;ved=0CBIQFjAA&amp;usg=AFQjCNE7JXUoNmThDNZwIcW1qq5QExQp6w"><b>Unknown Legend</b>]]
  for str in html:gmatch('/url%?q=(.-)&') do
    print(str)
  end
  local validUrl = playlist_gui.fixUrls(html)
  assertEquals(validUrl, [[<a href="http://www.lyricsfreak.com/n/neil%2Byoung/unknown%2Blegend_20099115.html"><b>Unknown Legend</b>]])
end

--[[
function TestPlaylistGui:testLaunchYoutube()
	playlist_api.setPlaylist({{artist='beatles', title='hey jude'}})
	playlist_gui.widget:modifySelection(1, 1, true)
	playlist_gui.widget:playOnYoutube(true)
end
--]]

function TestPlaylistGui:testFileStringToTable()
  local res = playlist_helpers.fileStringToTable([[a
b
c
d]])
  assertEquals(#res, 4)
  assertEquals(res[1], 'a')
end

function TestPlaylistGui:testDropFiles()
  playlist_api.setPlaylist({})
  playlist_gui.widget:dropFiles(F(system.getExecutablePath(), 'tests\\testM3ps'))
  local tracks = playlist_api.getPlaylist()
  assertEquals(#tracks, 2)
  assertEquals(tracks[1].artist, "beatles")
  assertEquals(tracks[1].title, "hey jude")
  assertEquals(tracks[2].artist, "neil young")
  assertEquals(tracks[2].title, "unknown legend")
end

function TestPlaylistGui:playInAudioPlayer()
  playlist_api.openPlaylist([[e:\sample music\sample_rel.sing]])
  playlist_gui.playInAudioPlayer(playlist_api.getPlaylist())
end

--TestPlaylistGui:playInAudioPlayer()
