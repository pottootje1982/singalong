require 'test_setup'
os.removeDir(LOCALAPPDATADIR, true)
require 'title_bar_gui'
require 'app'

local function downloadLyrics()
  config.downloadWhichMp3s = 'All'
  playlist_api.setPlaylist({
    {artist = 'beatles', title = 'hey jude'},
    {artist = 'neil young', title = 'unknown legend'},
    {artist = 'neil young', title = 'king'}
  })
  downloader.downloadLyrics()
end

-- We don't want this code to be executed when running unit tests
if not RUN_UNIT_TESTS then
  downloadLyrics()
end
