require 'misc'
require 'socketinterface'
require 'load_config'()
require 'playlist_helpers'
local convert = require('convert_html_to_ascii')

module('spotify_playlist', package.seeall)

local localAristMatch = '<div id="artist">.-<p class.->(.-)</p>'
local artistMatch = '<div id="artist">.-<a href.->(.-)</a>'
local titleMatch = '<a id="title".->(.-)</a>'
local urlMatch = '///([^/]+)/'

function parseSpotifyPlaylist(playlist)
  local songs = {}
  for url in playlist:gmatch('[^%c]+') do
    local content = socketinterface.open(url)
    local artist = content:match(artistMatch);
    if not artist then artist = content:match(localAristMatch) end
    local title = content:match(titleMatch)

    if not artist or not title then
      -- If nothing could be found from html file it could be that url is corrupt. Try to
      -- obtain artist and title from url itself
      -- This can occur in case mp3 artist tag or title tag are absent, url will be something
      -- like: http://open.spotify.com/local///1793+George+Harrison+-+Give+me+love/217
      local urlNormalized = replace(url, {'+', ' '})
      urlNormalized = urlNormalized:match(urlMatch)
      artist, title = playlist_helpers.extractArtistTitle(urlNormalized)
    else
      artist = convert(artist)
      title = convert(title)
    end
    if artist and title then
      table.insert(songs, {artist=artist, title = title})
    end
  end
  return songs
end

