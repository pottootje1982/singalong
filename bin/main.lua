-- Main.lua : script invoked directly from singalong.exe when no arguments are given

-- BUGS:
-- when pressing windows menu button, spawn menu at selected item location


-- TESTING:
-- check if solving CAPTCHA works

-- FEATURES
-- save songtekst in .sing file
-- button to restore default config (settings dialog)

require "misc"
require "app"
require "load_config"('APPDATA')
require "cache"
require "query"
require "playlist_gui"
require "searchsites_gui"
require "iup_getparam"
require "lyrics_gui"
require "miktex"
require "singalongpdf"
require "downloader"
require "title_bar_gui"
require "debug_frame"

local args = {...}

local playlistSitesSplitter =
  iup.split {
    value = config.playlistSitesSplitter,
    playlist_gui.widget.c,
    searchsites_gui.widget.c,
  }


local splitter = iup.split {
    orientation = 'HORIZONTAL',
    value = config.splitterValue,
    iup.hbox
    {
      gap="5",
      minsize='10x10',
      expandchildren='YES',
      playlistSitesSplitter,
      debug_frame.widget,
    },
    iup.vbox{
      iup.hbox
      {
        expand='HORIZONTAL',
        alignment = 'ACENTER',

        lyrics_gui.lyricsFileNameLabel,
        lyrics_gui.htmlToggle,
        lyrics_gui.saveLyricsButton,
      },
      lyrics_gui.lyricsMultiLine,
    },
  }

mainDialog = iup.dialog
{
  iup.frame
  {
    sunken = 'yes',
    expand = 'yes',
    iup.vbox
    {
      margin = "2x2",
      expand = 'yes',
      expandchildren = 'yes',
      title_bar_gui.widget,
      splitter,
    },
  },
  icon=singalong,
  title="SinGaLonG",
  resize="yes",
  shrink='yes',
  size=config.mainDialogSize,
  startfocus=playlist_gui.widget.c,
}

function mainDialog:resize_cb()
  playlist_gui.resize_cb()
end

local HINSTANCE = iup.GetGlobal('HINSTANCE')

function mainDialog:show_cb()
  setDialogIcon(mainDialog)
end

function mainDialog:k_any( key, press)
  if (key == iup.K_cn or key == iup.K_cN) then
    playlist_api.makeNewPlaylist()
  elseif (key == iup.K_co or key == iup.K_cO) then
    playlist_api.openPlaylist()
  elseif (key == iup.K_cd or key == iup.K_cD) then
    downloader.downloadLyrics()
  elseif (key == iup.K_cb or key == iup.K_cB) then
    title_bar_gui.createSongbook()
  elseif (key == iup.K_cp or key == iup.K_cP) then
    playlist_gui.widget:playOnYoutube()
  elseif (key == iup.K_cs or key == iup.K_cS) then
    playlist_api.saveMp3Table()
  elseif (key == iup.K_F1) then
    os.shellExecute('https://sites.google.com/site/walterreddock/home', 'html')
  else
    return iup.CONTINUE
  end
  return iup.IGNORE
end

function mainDialog:close_cb()
  playlist_api.saveMp3Table()
  config.mainDialogSize = mainDialog.size
  config.splitterValue = splitter.value
  config.playlistSitesSplitter = playlistSitesSplitter.value
  config.screenPosition = mainDialog.screenposition
  table.saveToFileText(F(LOCALAPPDATADIR, 'config.lua'), config)
  os.calcTime('Saving cache', function()
    cache.saveCache()
  end)
  saveSearchSites()
  iup.ExitLoop()
  mainDialog:destroy()
  destroyGui('playlist', 'searchsites')
  return iup.IGNORE
end

if args[1] then
  local fn = args[1]
  -- If not containing slash, we will assume file resides in working dir,
  -- we will make it into a full path however
  if not fn:find('\\') then
    fn = F(lfs.currentdir(), fn)
  end
  playlist_api.openPlaylist(fn)
end

if APPLOADED then
  updateGui('title_bar', 'lyrics')

  iup.SetHandle("mainDialog", mainDialog)
  if config.screenPosition then
    mainDialog:showxy(config.screenPosition:match('(%-?%d+),(%-?%d+)'))
  else
    mainDialog:show()
  end

  if config.loadplaylist then
    local succ, mess = pcall(function()
      playlist_api.openPlaylist(config.loadplaylist)
    end)
    if not succ then
      print('Something was wrong with playlist, clearing UI.')
      print(mess)
      playlist_api.setPlaylist({})
    end
  end

  iup.MainLoop()
end
