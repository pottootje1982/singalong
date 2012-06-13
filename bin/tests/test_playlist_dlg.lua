require 'load_config'()
require 'luaunit'

if not RUN_UNIT_TESTS then
  local res, entries = require 'playlist_dlg'([[Otis Redding	(Sittin' on) The dock of the bay
Bill Withers	Ain't no sunshine]])
  assertEquals(#entries, 2)
end
