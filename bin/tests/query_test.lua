require 'query'

TestQuery = {}

function TestQuery:testFormatFile()
  local s = os.format_file('html', {site='www.lyricssearch.net'}, {artist='beatles', title='hey jude'})
  local query = 'www.lyricssearch.net\\beatles - hey jude.html'
  local match = s:match(_(query))
  assertEquals(query, match)
end

function TestQuery:testQueryGoogle()
  assert(search_sites and #search_sites > 0, "No search sites defined!")
  local artist = 'neil young'
  local title='unknown legend'
  local content, fn = query.executeQuery(search_sites[4], {artist=artist, title=title}, true)
  assert(os.exists(fn), "file " .. fn .. " doesn't exist!")
  assert(content:match(artist))
  assert(content:match(title))
end

