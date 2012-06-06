require 'luaunit'
require 'cache'
require 'playlist_api'
require 'singalongpdf'
require 'test_setup'

function testGenerateSongbook()
  local tracks = playlist_api.gatherMp3Info(testDataDir('verukkelijke 715 zang.m3u'))
  tracks = {tracks[1], tracks[2], tracks[3], tracks[4]}
  local searchSite = search_sites[1]
  for i, track in ipairs(tracks) do
    local fn = os.format_bare_file(track.artist, track.title, 'txt')
    fn = testDataDir(fn)
    local content = os.read(fn)
    assert(content, 'File not found!')
    cache.addToCache(track, searchSite, os.format_file('txt', searchSite, track), content)
  end
  getPdfGenerator().generateSongbook(tracks, 'testGenerateSongbook')
end

if not RUN_UNIT_TESTS then
  testGenerateSongbook()
end
