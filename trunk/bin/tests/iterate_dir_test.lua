require 'misc'

IterateDirTest = {}

function IterateDirTest:testIterateDir()
  os.iterateDir('singalong', function(dir) print(dir) end, function(file) print(file) end)
end
