require 'luaunit'
require 'query'
require 'playlist_gui'

TestPlaylistGui = {}

--[=[
function TestPlaylistGui:testQueryGoogle()
  playlist_api.setPlaylist({{artist='beatles', title='hey jude'}})
	playlist_gui.widget:modifySelection(1, 1, true)
  local content, fn = playlist_gui.widget:queryGoogle(false)

  assert(content:match(playlist_gui.YOUTUBE_MATCH):match('http://www.youtube.com'))
end

function TestPlaylistGui:testLaunchYoutube()
	playlist_api.setPlaylist({{artist='beatles', title='hey jude'}})
	playlist_gui.widget:modifySelection(1, 1, true)
	playlist_gui.widget:playOnYoutube(true)
end
--]=]

function TestPlaylistGui:testFileStringToTable()
  local res = playlist_gui.fileStringToTable([[a
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
