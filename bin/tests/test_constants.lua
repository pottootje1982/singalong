require 'load_config'()
require 'luaunit'
require 'constants'

TestConstants = {}

function TestConstants:testTableFilter()
  config.fontSize = '30'
  local header = getHeader('songtekst')
  assert(header:find([[fontsize{30}{36}]]))
end
