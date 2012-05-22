require 'query'

TestQuery = {}

function TestQuery:testFormatFile()
  local s = os.format_file('html', {site='www.lyricssearch.net'}, {artist='beatles', title='hey jude'})
  local query = 'www.lyricssearch.net\\beatles - hey jude.html'
  local match = s:match(_(query))
  assert(query == match)
end

