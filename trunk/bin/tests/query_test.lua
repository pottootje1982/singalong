require 'query'
require 'luaunit'

TestQuery = {}

local testMp3 = {artist='neil young', title='unknown legend'}

function TestQuery:testFormatFile()
  local s = os.format_file('html', {site='www.lyricssearch.net'}, {artist='beatles', title='hey jude'})
  local query = 'www.lyricssearch.net\\beatles - hey jude.html'
  local match = s:match(_(query))
  assertEquals(query, match)
end

function TestQuery:testQueryGoogle()
  assert(search_sites and #search_sites > 0, "No search sites defined!")
  local content, fn = query.executeQuery(search_sites[4], testMp3, true)
  assert(os.exists(fn), "file " .. fn .. " doesn't exist!")
  assert(content:match(testMp3.artist))
  assert(content:match(testMp3.title))
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

function TestQuery:testExtractUnexistingLyrics()
  local artist = 'Some weird band name'
  local title='Some weird title'
  local search_site = search_sites[4]
  local mp3 = {artist=artist, title=title}
  local fileName = os.format_file('html', search_site, mp3)
  local lyrics = query.extractLyrics(search_site, mp3)
  assert(not lyrics, "Lyrics are returned!")
end


function TestQuery:testExtractLyrics()
  local search_site = search_sites[1]
  local fileName = os.format_file('html', search_site, testMp3)
  os.copy(testMp3.artist .. ' - ' .. testMp3.title .. '.html', os.getPath(fileName))
  -- we've to add it to cache first otherwise getLyrics won't find it
  cache.addToCache(testMp3, search_site, fileName)
  local lyrics = query.extractLyrics(search_site, testMp3)
  assert(lyrics)
end

function TestQuery:testDownloadLyrics()
  local searchSite = search_sites[4]
  query.downloadLyrics(testMp3, {searchSite})
  local txtFn = os.format_file('txt', searchSite, testMp3)
  local htmlFn = os.format_file('html', searchSite, testMp3)
  assert(os.exists(txtFn))
  assert(os.exists(htmlFn))

  local songQuery = 'she used to work in a diner'

  local fn, lyrics = query.getLyrics('txt', searchSite, testMp3)
  assert(lyrics)
  assert(os.exists(fn))
  assertEquals(lyrics:lower():match(songQuery):lower(), songQuery:lower())

  local fn, html = query.getLyrics('html', searchSite, testMp3)
  assert(html)
  assert(os.exists(fn))
  assertEquals(html:lower():match(songQuery):lower(), songQuery:lower())
end

