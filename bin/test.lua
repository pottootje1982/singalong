_G.HIDE_GUI = true
require 'main'

-- Test script: use to your liking!

--print(query.getLyrics('txt', search_sites[4], {artist='Charles Aznavour', title='La Mama'}))
--local cont = query.extractLyrics(search_site, {artist='Blues Brothers', title='Everybody Needs Somebody to Love'})
--miktex.viewTexFile([[top 2000 zang]], true)
--miktex.generateSongbook(playlist_api.getPlaylist(), [[top40]])
--print(cont)

-- os.shellExecute([[www.google.com]], 'html')
--socketinterface.request([[http://www.google.com/sorry/image?id=4143580117029869510&amp;hl=en]], 'test.jpg')


--[[
require 'progress_dialog'
--local dialogCreator = progress_dialog.getDialogCreator()
local progressDialog, updateLabel, downloadProgressbar = progress_dialog.getDialog("Downloading lyrics...", "Downloading lyrics:", closeCallback, "Stop downloading", closeCallback)

progressDialog:show()

iup.MainLoop()
--]]
