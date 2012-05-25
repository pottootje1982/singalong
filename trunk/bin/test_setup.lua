local executablePath = system.getExecutablePath()
TEST_PATH = executablePath .. 'tests'
package.path = package.path .. ';' .. TEST_PATH .. '\\?.lua'

require 'load_config'(TEST_PATH)
require 'misc'
require 'lfs'
