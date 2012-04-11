-- mem leak
-- font sizes for singalong pdf
-- remove \\ from standard ascii files, replace with newlines
-- remove multiple selection
-- progress bar multiple site selection klopt nog niet (1 song)
-- save button
-- gray out both save buttons if song/playlist was just saved, so unedited

-- check &quot; somewhere in the zwarte lijst
-- check if solving CAPTCHA works

-- Nice to have:
-- Configurable lyrics_dir (lyrics_dir shouldn't be appended before cached items for this)
-- playback of playlist

require "misc"
require "app"
require "load_config"
require "cache"
require "query"
require "playlist_gui"
require "searchsites_gui"
require "lyrics_gui"
require "miktex"
require "singalongpdf"
require "icon"

dofile  "gui_impl.lua"
dofile  "compare_playlists.lua"

local args = {...}

local debugFrame
if _DEBUG then
  debugFrame =
    iup.frame
    {
      title="Debugging",
      expand="vertical",
      maxsize='150x',
      iup.vbox
      {

        testButton, reloadButton,
        iup.button
        {title="Debug", expand="HORIZONTAL",
          action = function(self)
            dofile 'reload.lua'
            debug.debug()
          end,
          bgcolor = "255 0 0",
        },
        compareButton,
        expand = 'no',
        homogeneous = 'yes',
      },
    }
end

local playlistSitesSplitter = iup.split {
  value = config.playlistSitesSplitter,
  playlist_gui.widget.c,
  iup.hbox
  {
    gap="5",
    expand='YES',
    minsize='200x',

    searchsites_gui.widget.c,
    debugFrame,
  },
}

local splitter = iup.split {
    orientation = 'HORIZONTAL',
    value = config.splitterValue,
    playlistSitesSplitter,
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
      iup.hbox
      {
        gap="5",
        expand="horizontal",

        newPlaylistButton,
        openPlaylistButton,
        sortButton,
        downloadLyricsButton,
        createSongbookButton,
        iup.label{title = "", expand = "HORIZONTAL"}, -- Tried to do this with iup.fill but this doesn't work...
        settingsButton,
      },
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

function setDialogIcon(dialog)
  system.setIcon(HINSTANCE, dialog.title)
end

function mainDialog:show_cb()
  setDialogIcon(mainDialog)
end

function mainDialog:k_any( key, press)
  if (key == iup.K_cn or key == iup.K_cN) then
    playlist_api.makeNewPlaylist()
  elseif (key == iup.K_co or key == iup.K_cO) then
    playlist_api.openPlaylist()
  elseif (key == iup.K_cd or key == iup.K_cD) then
    downloadLyricsButton:action()
  elseif (key == iup.K_cb or key == iup.K_cB) then
    createSongbookButton:action()
  elseif (key == iup.K_cp or key == iup.K_cP) then
    playlist_gui.widget:playOnYoutube()
  elseif (key == iup.K_cs or key == iup.K_cS) then
    playlist_api.saveMp3Table()
  elseif (key == iup.K_F1) then
    os.shellExecute('https://sites.google.com/site/walterreddock/home', 'html')
  end
end

function mainDialog:close_cb()
  playlist_api.saveMp3Table()
  config.mainDialogSize = mainDialog.size
  config.splitterValue = splitter.value
  config.playlistSitesSplitter = playlistSitesSplitter.value
  table.saveToFileText(F(LOCALAPPDATADIR, 'config.lua'), config)
  os.calcTime('Saving cache', function()
    cache.saveCache()
  end)
  saveSearchSites()
  iup.ExitLoop()
  mainDialog:destroy()
  return iup.IGNORE
end

if args[1] then
  local fn = args[1]
  -- If not containing slash, we will assume file resides in working dir,
  -- we will make it into a full path however
  if not fn:find('\\') then
    fn = F(lfs.currentdir(), fn)
  end
  openPlaylistButton:action(fn)
end

if APPLOADED then
  activateButtons()

  mainDialog:show()

  if config.loadplaylist then
    openPlaylistButton:action(config.loadplaylist)
  end

  iup.MainLoop()
end
