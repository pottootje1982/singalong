require 'luaunit'
require 'cache'
require 'playlist_api'
require 'singalongpdf'

_TestSingalongPdf = {}

function _TestSingalongPdf:testGenerateSongbook()
  local tracks = playlist_api.gatherMp3Info(F(system.getExecutablePath(), 'verukkelijke 715 zang.m3u'))
  tracks = {tracks[1], tracks[2], tracks[3], tracks[4]}
  local searchSite = search_sites[1]
  for i, track in ipairs(tracks) do
    local fn = os.format_bare_file(track.artist, track.title, 'txt')
    fn = F(system.getExecutablePath(), 'tests', fn)
    cache.addToCache(track, searchSite, os.format_file('txt', searchSite, track), os.read(fn))
  end
  getPdfGenerator().generateSongbook(tracks, 'testGenerateSongbook')
end
