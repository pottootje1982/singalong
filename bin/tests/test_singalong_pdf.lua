require 'luaunit'
require 'cache'
require 'playlist_api'
require 'singalongpdf'

TestSingalongPdf = {}

function TestSingalongPdf:testGenerateSongbook()
  local tracks = playlist_api.gatherMp3Info(F(system.getExecutablePath(), 'verukkelijke 715 zang.m3u'))
  tracks = {tracks[1], tracks[2], tracks[3], tracks[4]}
  local searchSite = search_sites[1]
  for i, track in ipairs(tracks) do
    cache.addToCache(track, searchSite, os.format_file('txt', searchSite, track))
  end
  table.print(tracks)
  getPdfGenerator().generateSongbook(tracks, 'testGenerateSongbook')
end
