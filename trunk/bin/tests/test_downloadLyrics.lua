require 'title_bar_gui'

local function downloadLyrics()
  title_bar_gui.downloadLyrics()
end

-- We don't want this code to be executed when running unit tests
if not TEST_PATH then
  downloadLyrics()
end
