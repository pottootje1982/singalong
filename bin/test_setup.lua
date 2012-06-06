require 'misc'

local executablePath = system.getExecutablePath()
TEST_PATH = F(executablePath, 'tests')
package.path = package.path .. ';' .. TEST_PATH .. '\\?.lua'

function testDataDir(file)
  return F(TEST_PATH, 'testdata', file)
end

require 'load_config'(TEST_PATH)
require 'lfs'
