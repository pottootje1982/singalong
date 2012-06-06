require 'load_config'()
require 'miktex'
require 'test_setup'
require 'misc'

TestMiktex = {}

function TestMiktex:testViewTexFile()
  os.shellExecute(' tests/test_miktex.lua pause', 'singalong.exe', nil, system.getExecutablePath())
  assert(os.exists(testDataDir('test.pdf')))
end

if not RUN_UNIT_TESTS then
  miktex.viewTexFile(testDataDir('test'), false)
end


