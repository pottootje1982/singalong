
TestPlaylistApi = {}

function TestPlaylistApi:testExtractFromFile()
  fileStr = [[10CC - Dreadlock Holiday]]
  local artist, title = playlist_api.extractFromFile(fileStr)
  assertEquals(artist, '10CC')
  assertEquals(title, 'Dreadlock Holiday')
end
