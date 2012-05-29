require 'playlist_helpers'

TestPlaylistApi = {}

function TestPlaylistApi:testExtractArtistTitle()
  fileStr = [[10CC - Dreadlock Holiday]]
  local artist, title = playlist_helpers.extractArtistTitle(fileStr)
  assertEquals(artist, '10CC')
  assertEquals(title, 'Dreadlock Holiday')
end
