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
