-- load_config: Config file that will be read when config.lua is not available

require 'misc'

local configLoaded
EXECUTABLE_PATH = system.getExecutablePath()

local configDefaults = {
  downloadSelSites = false,
  fontSize = "12",
  fontColor = '0 0 0',
  stopAfterFirstHit = true,
  preview = true,
  wait = 1.000000,
  maxWait = 8.000000,
  twoside = true,
  avoidPageBreaks = false,
  downloadWhichMp3s = 'Unfound',
  --proxy = "http://nly40920:Gerstowich2011@nl042-cips1.piap.philips.net:8080",
  mainDialogSize = "FULLxFULL",
  minWait = 5.000000,
  pdfGenerator = 'Singalong pdf',
  miktexDir = [[c:\miktex]],
  audioPlayerLocation = [[]],
  artistTitleMatch = '(.-)%s+%-%s+(.+)'
}

local function createDefaultConfig()
  os.createDir(LOCALAPPDATADIR)
  config = configDefaults
  table.saveToFileText(F(LOCALAPPDATADIR, 'config.lua'), config)
end

local function loadConfig(singalongPath)
  -- Only allow config to be loaded once
  if configLoaded then return end
  -- Global var used to determine whether test code can be launched
  local localAppData = os.getenv('LOCALAPPDATA')
  local appData = os.getenv('APPDATA')
  verify(localAppData or appData, '%LOCALAPPDATA% or %APPDATA% directory not found in environment variables!')
  if not singalongPath or singalongPath == 'APPDATA' then
    LOCALAPPDATADIR = F(localAppData or appData, 'SinGaLonG')
  else
    LOCALAPPDATADIR = F(singalongPath or localAppData or appData, 'SinGaLonG')
  end
  _G.LYRICS_DIR = F(LOCALAPPDATADIR, 'lyrics')

  local succ, mess = pcall(function()
    print('Loading config file...')
    config = dofile(F(LOCALAPPDATADIR, "config.lua"))
  end)
  if not succ then
    print("Config doesn't exist, or something was wrong with config file, creating new one")
    createDefaultConfig()
  end

  -- if an entry in the config table got deleted, we get it from configDefaults
  for i, v in pairs(configDefaults) do
    if config[i] == nil then
      config[i] = v
    end
  end

  configLoaded = true
end

return loadConfig
