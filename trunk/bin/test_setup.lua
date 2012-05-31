require 'misc'

local executablePath = system.getExecutablePath()
TEST_PATH = F(executablePath, 'tests')
package.path = package.path .. ';' .. TEST_PATH .. '\\?.lua'

require 'load_config'(TEST_PATH)
require 'lfs'
