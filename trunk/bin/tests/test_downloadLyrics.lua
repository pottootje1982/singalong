require 'test_setup'
os.removeDir(LOCALAPPDATADIR, true)
require 'title_bar_gui'

local function downloadLyrics()
  config.downloadWhichMp3s = 'All'
  playlist_api.setPlaylist({
    {artist = 'beatles', title = 'hey jude'},
    {artist = 'neil young', title = 'unknown legend'},
    {artist = 'neil young', title = 'king'}
  })
  title_bar_gui.downloadLyrics()
end

-- We don't want this code to be executed when running unit tests
if not RUN_UNIT_TESTS then
  downloadLyrics()
end
