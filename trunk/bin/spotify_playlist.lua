require 'misc'
require 'socketinterface'
require 'load_config'()
require 'playlist_helpers'
local convert = require('convert_html_to_ascii')

module('spotify_playlist', package.seeall)

local musicianUrlMatch = '<meta property="music:musician" content="(.-)">'
local titleMatch = '<meta property="og:title" content="(.-)">'
local durationMatch = '<meta property="music:duration" content="(.-)">'
local urlMatch = '///([^/]+)/'

function parseSpotifyPlaylist(playlist)
  local songs = {}
  for url in playlist:gmatch('[^%c]+') do
    (function() -- this construct is used to be able to use return as a continue statement
      local content = socketinterface.open(url)
      if not content then return end
      local musician
      local musicianUrl = content:match(musicianUrlMatch)
      if musicianUrl then
        local musicianContent = socketinterface.open(musicianUrl)
        if musicianContent then
          musician = musicianContent:match(titleMatch)
        end
      end
      local title = content:match(titleMatch)
      local duration = content:match(durationMatch)

      if not musician or not title then
        -- If nothing could be found from html file it could be that url is corrupt. Try to
        -- obtain musician and title from url itself
        -- This can occur in case mp3 artist tag or title tag are absent, url will be something
        -- like: http://open.spotify.com/local///1793+George+Harrison+-+Give+me+love/217
        local urlNormalized = replace(url, {'+', ' '})
        urlNormalized = urlNormalized:match(urlMatch)
        if urlNormalized then
          musician, title = playlist_helpers.extractArtistTitle(urlNormalized)
        end
      else
        musician = convert(musician)
        title = convert(title)
      end
      if musician and title then
        table.insert(songs, {artist=musician, title = title, duration = duration})
      end
    end)()
  end
  return songs
end

local function calcDuration(songs)
  local duration = 0
  for i, song in ipairs(songs) do
    duration = duration + tonumber(song.duration)
  end
  return duration
end

if not APPLOADED then
  local songs = parseSpotifyPlaylist([[http://open.spotify.com/track/4uVwWEfbrSKLcPj0kKrUPp]])
  local duration = calcDuration(songs)
  local min, sec = math.modf(duration / 60)
  print(string.format("Duration of playlist is %d:%d", min, sec * 60))
  table.saveToFileText("tripping.sing", songs)
end
