require 'test_setup'
require 'playlist_api'

-- We don't want this code to be executed when running unit tests
if not RUN_UNIT_TESTS then
  local res = playlist_api.showNewPlaylistDialog(testDataDir('verukkelijke 715 zang.sing'))
  print(res)
end
