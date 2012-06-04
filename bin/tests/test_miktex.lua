require 'load_config'()
require 'miktex'

TestMiktex = {}

function TestMiktex:testViewTexFile()
  if os.exists(config.miktexDir) then
    miktex.viewTexFile(F(system.getExecutablePath(), 'tests\\test'), true)
    assert(os.exists(F(system.getExecutablePath(), 'tests\\test.pdf')))
  end
end

TestMiktex:testViewTexFile()
