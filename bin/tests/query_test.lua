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

function TestQuery:testGetLyricFragment()
  local html =
  [[<div class="adsdiv">
<img src="http://www.justsomelyrics.com/images/phone.gif" alt="phone" /><a href="http://www.ringtonematcher.com/go/?sid=JSOLros&artist=Boudewijn+de+Groot&song=De+zwembadpas" class="ads" rel="nofollow" > Send "De zwembadpas" Ringtone to your Cell </a><img src="http://www.justsomelyrics.com/images/phone2.gif" alt="phone" />
</div>
lyric content<div class="adsdiv">]]
  local lyrics = query.getLyricFragment(html, "<div.->.-<img.-/><a.->.-</a><img.-/>%c</div>%c", "<div.->")
  assertEquals(lyrics, "lyric content")
end


