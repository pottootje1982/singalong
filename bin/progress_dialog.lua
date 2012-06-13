module('progress_dialog', package.seeall)

function getDialog(title, activityLableTitle, buttonCallback, buttonTitle, closeCallback)
  local updateLabel = iup.label{alignment="ACENTER", expand="HORIZONTAL"}
  local progressBar = iup.progressbar {expand="HORIZONTAL"}
  local progressDialog = iup.dialog
  {
    iup.vbox
    {
      iup.label{title=activityLableTitle},
      updateLabel,
      progressBar,
      buttonCallback and iup.button{
        action = buttonCallback,
        title=buttonTitle,
      },
      gap="5",
      margin = "5x5",
      alignment = "ACENTER",
    },
    close_cb = closeCallback,
    show_cb = function(dialog)
      setDialogIcon(dialog)
    end,
    title = title,
    hidetaskbar = 'YES',
    toolbox = 'YES',
    parentdialog = 'mainDialog',

    menubox = "NO",
    resize = "NO",
    --minsize="400x100", -- causes app to crash in combination with parentdialog = 'mainDialog'
    size="400x100",
  }
  return progressDialog, updateLabel, progressBar
end
