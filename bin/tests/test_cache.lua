require 'cache'

cache.LEVENSHTEIN_ARTIST_TRESHOLD = 0.5
cache.LEVENSHTEIN_TITLE_TRESHOLD = 0.8

TestCache = {}

local search_site = search_sites[4]
local testMp3 = {artist='neil young', title='unknown legend'}
local testMp3Name = os.format_file('txt', search_site, testMp3)

function TestCache:testScanCache()
  cache.buildCache()
  local hits = cache.scanCache(testMp3, search_site)
  assert(not hits)
  cache.addToCache(testMp3, search_site, testMp3Name)
  hits = cache.scanCache(testMp3, search_site)
  assert(hits)
  -- rescan param should be true in order for the levenshtein algorithm to be used
  hits = cache.scanCache({artist='young', title='Unkown Legend'}, search_site, true)
  assert(hits)
  -- when artist similarity is less than 50%, we expect nothing to be found
  hits = cache.scanCache({artist='you', title='Unkown Legend'}, search_site, true)
  assert(not hits)
end

function TestCache:testSaveCache()
  cache.addToCache(testMp3, search_site, testMp3Name)
  cacheFileName = testFile('cache.lua.txt')
  cache.saveTxtCache(cacheFileName)
  assert(os.exists(cacheFileName))
  local testCache = dofile(cacheFileName)
  local entry = testCache[testMp3.artist][testMp3.title][search_site.site]
  assert(entry)
  assertEquals(entry.artist, testMp3.artist)
  assertEquals(entry.title, testMp3.title)
  assertEquals(entry.site, search_site.site)
end
