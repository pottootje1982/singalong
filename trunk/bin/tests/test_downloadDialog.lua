require 'load_config'()

-- We don't want this code to be executed when running unit tests
if not RUN_UNIT_TESTS then
  require 'download_dialog'()
end
