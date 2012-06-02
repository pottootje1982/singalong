require 'load_config'()
require 'miktex'

TestMiktex = {}

function TestMiktex:testViewTexFile()
  miktex.viewTexFile(F(system.getExecutablePath(), 'tests\\test'), true)
  assert(os.exists(F(system.getExecutablePath(), 'tests\\test.pdf')))
end

TestMiktex:testViewTexFile()
