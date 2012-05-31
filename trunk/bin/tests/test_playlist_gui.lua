require 'luaunit'
require 'query'
require 'playlist_gui'

TestPlaylistGui = {}

function TestPlaylistGui:testQueryGoogle()
  mp3s = {{artist='beatles', title='hey jude'}}
	playlist_gui.widget:modifySelection(1, 1, true)
  local content, fn = playlist_gui.widget:queryGoogle(false)

  assert(content:match(playlist_gui.YOUTUBE_MATCH):match('http://www.youtube.com'))
end

function TestPlaylistGui:testLaunchYoutube()
	mp3s = {{artist='beatles', title='hey jude'}}
	playlist_gui.widget:modifySelection(1, 1, true)
	playlist_gui.widget:playOnYoutube(true)
end

function TestPlaylistGui:testFileStringToTable()
  local res = playlist_gui.fileStringToTable([[a
b
c
d]])
  assertEquals(#res, 4)
  assertEquals(res[1], 'a')
end

function TestPlaylistGui:testDropFiles()
  mp3s = {}
  playlist_gui.widget:dropFiles(F(system.getExecutablePath(), 'tests\\testM3ps'))
  assertEquals(#mp3s, 2)
  assertEquals(mp3s[1].artist, "beatles")
  assertEquals(mp3s[1].title, "hey jude")
  assertEquals(mp3s[2].artist, "neil young")
  assertEquals(mp3s[2].title, "unknown legend")
end

TestPlaylistGui:testDropFiles()
