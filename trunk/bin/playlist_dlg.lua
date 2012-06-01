module('playlist_dlg', package.seeall)

return function(sample)
  local playlistEntries = nil
  local multiline = iup.text{expand = 'YES', multiline = 'YES', value = sample}

  local function okFunction()
    playlistEntries = playlist_helpers.gatherFromCustomPlaylist(multiline.value)
    return iup.CLOSE
  end

  local function spotifyFunction()
    playlistEntries = spotify_playlist.parseSpotifyPlaylist(multiline.value)
    return iup.CLOSE
  end

  local playlistDlg = iup.dialog
  {
    iup.vbox
    {
      iup.label{title="Give multiple artist - title entries on each line:"},
      multiline,
      iup.hbox
      {
        iup.button
        {
          title = 'OK',
          action = okFunction,
        },
        iup.button
        {
          title = 'Import from spotify',
          action = spotifyFunction,
        },
        iup.button
        {
          title = 'Cancel',
          action = function()
            return iup.CLOSE
          end
        },
      },
      gap="5",
      margin = "5x5",
      alignment = "ACENTER",
    },
    k_any = function(widget, key, press)
      if (key == iup.K_ESC) then
        return iup.CLOSE
      elseif (key == iup.K_cCR) then
        return okFunction()
      end
    end,

    title = "Enter playlist...",
    parentdialog = mainDialog,
    menubox = "NO",
    resize = "NO",
    minsize="400x300",
    size="400x300",
  }

  local res = iup.Popup(playlistDlg, iup.ANYWHERE, iup.ANYWHERE)
  setDialogIcon(playlistDlg)
  return res, playlistEntries
end
