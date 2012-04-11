-------------------------------------------------------------------
-- only ExitDialog.wxs and
-- WixUI_InstallDir.wxs are customized for our installer
-------------------------------------------------------------------

local installerDir = lfs.currentdir() .. [[\ui]]
checkOutDir = [[C:\Users\nly40920\Desktop\sing]]

execute([[del *.wixobj]])
execute([[del *.wixlib]])

local wxsFiles =
{
  "ServerDlg.wxs",
  "BrowseDlg.wxs",
  "CancelDlg.wxs",
  "Common.wxs",
  "DiskCostDlg.wxs",
  "ErrorDlg.wxs",
  "ErrorProgressText.wxs",
  "ExitDialog.wxs",
  "FatalError.wxs",
  "FilesInUse.wxs",
  "InstallDirDlg.wxs",
  "LicenseAgreementDlg.wxs",
  "MaintenanceTypeDlg.wxs",
  "MaintenanceWelcomeDlg.wxs",
  "MsiRMFilesInUse.wxs",
  "OutOfDiskDlg.wxs",
  "OutOfRbDiskDlg.wxs",
  "PrepareDlg.wxs",
  "ProgressDlg.wxs",
  "ResumeDlg.wxs",
  "UserExit.wxs",
  "VerifyReadyDlg.wxs",
  "WaitForCostingDlg.wxs",
  "WelcomeDlg.wxs",
  "WixUI_InstallDir.wxs",
}

local wxsFilesString = ''
for i, file in ipairs(wxsFiles) do
  wxsFilesString = wxsFilesString .. string.format([[%s\%s ]], installerDir, file)
end

executePath(WIX_LOCATION, [[candle -nologo -o %s\ %s -dlicenseRtf="License.rtf" -dbannerBmp=.\bitmaps\bannrbmp.bmp -ddialogBmp=.\bitmaps\dlgbmp.bmp -dexclamationIco=.\bitmaps\exclamic.ico -dinfoIco=.\bitmaps\info.ico -dnewIco=.\bitmaps\New.ico -dupIco=.\bitmaps\Up.ico -dprinteulaDll=..\Helper.dll]], installerDir, wxsFilesString)

local wixObjFiles = {
  "BrowseDlg.wixobj",
  "CancelDlg.wixobj",
  "Common.wixobj",
  "DiskCostDlg.wixobj",
  "ErrorDlg.wixobj",
  "ErrorProgressText.wixobj",
  "ExitDialog.wixobj",
  "FatalError.wixobj",
  "FilesInUse.wixobj",
  "InstallDirDlg.wixobj",
  "LicenseAgreementDlg.wixobj",
  "MaintenanceTypeDlg.wixobj",
  "MaintenanceWelcomeDlg.wixobj",
  "MsiRMFilesInUse.wixobj",
  "OutOfDiskDlg.wixobj",
  "OutOfRbDiskDlg.wixobj",
  "PrepareDlg.wixobj",
  "ProgressDlg.wixobj",
  "ResumeDlg.wixobj",
  "UserExit.wixobj",
  "VerifyReadyDlg.wixobj",
  "WaitForCostingDlg.wixobj",
  "WelcomeDlg.wixobj",
  "WixUI_InstallDir.wixobj",
}

local wixObjFilesString = ''
for i, file in ipairs(wixObjFiles) do
  wixObjFilesString = wixObjFilesString .. string.format([[%s\%s ]], installerDir, file)
end

executePath(WIX_LOCATION, [[lit.exe -nologo -out %s\wixui.wixlib %s]], installerDir, wixObjFilesString)
