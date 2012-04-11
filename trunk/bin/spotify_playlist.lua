require 'misc'
require 'socketinterface'
require 'load_config'
local convert = require('convert_html_to_ascii')

module('spotify_playlist', package.seeall)

local localAristMatch = '<div id="artist">.-<p class.->(.-)</p>'
local artistMatch = '<div id="artist">.-<a href.->(.-)</a>'
local titleMatch = '<a id="title".->(.-)</a>'

function parseSpotifyPlaylist(playlist)
  local songs = {}
  for url in playlist:gmatch('[^%c]+') do
    local content = socketinterface.open(url)
    local artist = content:match(artistMatch);
    if not artist then artist = content:match(localAristMatch) end
    local title = content:match(titleMatch)
    artist = convert(artist)
    title = convert(title)
    if artist and title then
      table.insert(songs, {artist=artist, title = title})
    end
  end
  return songs
end

if not APPLOADED then
  local playlist = dofile 'spotify.lua'
  local songs = parseSpotifyPlaylist(playlist)
  table.print(songs)
end
