require 'luaunit'
require 'load_config'()
require 'playlist_helpers'
require 'misc'

TestPlaylistHelpers = {}

function TestPlaylistHelpers:testGatherFromCustomPlaylist()
  config.artistTitleMatch = '(.-)%s+%-%s+(.+)'
  local tracks = playlist_helpers.gatherFromCustomPlaylist([[The Beatles - Yellow Submarine
Neil Young - Old man
]])
  table.areEquals(tracks,
  {
    {
      artist="The Beatles",
      title="Yellow Submarine",
    },
    {
      artist="Neil Young",
      title="Old man",
    }
  })
end

function TestPlaylistHelpers:testGatherFromCustomPlaylist2()
  config.artistTitleMatch = '%d+\t(.-)\t(.*)\t%d+'
  local tracks = playlist_helpers.gatherFromCustomPlaylist([[200	Tom Jones	Help Yourself	1968
199	Udo Jurgens	Mercy Cherie	1966
198	Mama's & Papa's	Monday Monday	1966
197	Lucille Starr	The French Song	1964
196	Ronnie Tober	Geweldig	1965
195	Sandpipers	Guantanamera	1966
194	Bobby Goldsboro	Honey	1968
193	Gerhard Wendland	Tanze Mit Mir In Den Morgen	1962
192	Perry Como	Catarina	1962
191	Percy Sledge	My Special Prayer	1969
190	Trio Hellenique	La Danse de Zorba	1965
189	Louis Armstrong	Hello Dolly	1964
188	Ben Cramer	Zai Zai Zai	1967
187	Gilbert Becaud	Et Maitenant	1961
186	Brenda Lee	All Alone Am I	1963
185	Nancy Sinatra & Frank Sinatra	Somethin' Stupid	1967]])
  table.areEquals(tracks[1],
    {
      artist="Tom Jones",
      title="Help Yourself",
    })
  table.areEquals(tracks[2],
    {
      artist="Udo Jurgens",
      title="Mercy Cherie",
    })
  table.areEquals(tracks[16],
    {
      artist="Nancy Sinatra & Frank Sinatra",
      title="Somethin' Stupid",
    })
  assertEquals(#tracks, 16)
end
