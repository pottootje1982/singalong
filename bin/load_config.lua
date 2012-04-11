-- Config file that will be read when config.lua is not available

require 'misc'

-- Global var used to determine whether test code can be launched
local localAppData = os.getenv('LOCALAPPDATA')
local appData = os.getenv('APPDATA')
misc.verify(localAppData or appData, '%LOCALAPPDATA% or %APPDATA% directory not found in environment variables!')
LOCALAPPDATADIR = F(localAppData or appData, 'SinGaLonG')
_G.LYRICS_DIR = F(LOCALAPPDATADIR, 'lyrics')


local configDefaults = {
  downloadSelSites = false,
  fontSize = "normalsize",
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
}

if APPLOADED then -- has to be disabled for socketinterface
  if not lfs.attributes(F(LOCALAPPDATADIR, 'config.lua')) then
    os.createDir(LOCALAPPDATADIR)
    config = configDefaults
    table.saveToFileText(F(LOCALAPPDATADIR, 'config.lua'), config)
  else
    print('Loading config file...')
    config = dofile(F(LOCALAPPDATADIR, "config.lua"))
  end

  -- if an entry in the config table got deleted, we get it from configDefaults
  for i, v in pairs(configDefaults) do
    if config[i] == nil then 
      config[i] = v
    end
  end
else
  config = dofile(F(LOCALAPPDATADIR, "config.lua"))
end
