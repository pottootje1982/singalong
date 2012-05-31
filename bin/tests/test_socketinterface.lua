require 'socketinterface'

TestSocketInterface = {}

function TestSocketInterface:testRequest()
  local neilYoungQuery = testFile('neilyoungquery.html')
  socketinterface.request('http://www.google.com/search?q=neil+young+unknown+legend+site%3Awww.lyricsfreak.com', neilYoungQuery)
  os.exists(neilYoungQuery)
  local content = os.read(neilYoungQuery)
  assert(content)
  local queryArtist = 'neil young'
  local queryTitle = 'unknown legend'
  assertEquals(content:lower():match(queryArtist), queryArtist)
  assertEquals(content:lower():match(queryTitle), queryTitle)
end

function TestSocketInterface:getCaptchaFile()
  socketinterface.request([[http://www.google.com/sorry/image?id=4143580117029869510&amp;hl=en]], 'test.jpg')
end
