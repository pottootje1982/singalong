require 'misc'

TestIterateDir = {}

function TestIterateDir:testIterateDir()
  os.iterateDir('singalong', function(dir) print(dir) end, function(file) print(file) end)
end

function TestIterateDir:testGatherFiles()
  local files = os.gatherFiles(F(system.getExecutablePath(), 'tests'), 'lua')
  assert(table.find(files, function(i, file) return file:find('config_test.lua', nil, true) end))
end
