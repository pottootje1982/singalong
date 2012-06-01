module('debug_frame', package.seeall)

testButton = iup.button{title="run unit tests",expand="YES"}
function testButton:action()
  os.shellExecute(' run_tests.lua pause', 'singalong.exe', nil, system.getExecutablePath())
end

compareButton = iup.button{title="Compare with playlist",expand="YES"}
function compareButton:action()
  local fn = showPlaylistDialog()
  if fn then
    local doubles, mp3Strings = comparePlaylists(playlist_api.getPlaylistName(), fn)
    listContent = table.concat(mp3Strings, '|')
    local ret, selMp3 = iup.GetParam("Double tracks", nil, #doubles .. " double tracks%l|" .. listContent .. "|\n", 1)
  end
end

if _DEBUG then
  widget =
    iup.frame
    {
      title="Debugging",
      expand="vertical",
      maxsize='150x',
      iup.vbox
      {

        testButton,
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
