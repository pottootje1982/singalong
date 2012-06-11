module('playlist_helpers', package.seeall)

local lineMatch = '[^\n]*'
local artist_title = '([^\n]-)%s+%-%s+([^\n]+)'

function getArtistTitleExtMatch()
  return artist_title .. '%.([^.]+)$'
end

function fileStringToTable(fileList)
  local result = {}
  for line in fileList:gmatch('[^%c]+') do
    table.insert(result, line)
  end
  return result
end

function gatherFromCustomPlaylist(playlist)
  local tracks = {}
  for line in playlist:gmatch(lineMatch) do
    local artist, title = line:match(config.artistTitleMatch)
    if artist and title then
      table.insert(tracks, {artist = artist, title = title})
    end
  end

  return tracks
end

function extractArtistTitle(fileStr)
  local artist, title = fileStr:match("^%(?[%d]*%)?[%.]*[%.%- ]+" .. artist_title)
  if not artist then
    artist, title = fileStr:match(artist_title)
  end
  return artist, title
end

