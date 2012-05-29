module('playlist_helpers', package.seeall)

artist_title = '([^%c]-)%s+%-%s+([^%c]+)'
artist_title_ext = artist_title .. '%.([^.]+)$'

function gatherFromCustomPlaylist(playlist)
  local tracks = {}
  for artist, title in playlist:gmatch(artist_title) do
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

