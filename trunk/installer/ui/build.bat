@echo off
rem -----------------------------------------------------------------
rem only ExitDialog.wxs and 
rem WixUI_InstallDir.wxs are customized for our installer
rem -----------------------------------------------------------------

del *.wixobj
del *.wixlib

candle -nologo ServerDlg.wxs ^
              BrowseDlg.wxs ^
              CancelDlg.wxs ^
              Common.wxs ^
              DiskCostDlg.wxs ^
              ErrorDlg.wxs ^
              ErrorProgressText.wxs ^
              ExitDialog.wxs ^
              FatalError.wxs ^
              FilesInUse.wxs ^
              InstallDirDlg.wxs ^
              LicenseAgreementDlg.wxs ^
              MaintenanceTypeDlg.wxs ^
              MaintenanceWelcomeDlg.wxs ^
              MsiRMFilesInUse.wxs ^
              OutOfDiskDlg.wxs ^
              OutOfRbDiskDlg.wxs ^
              PrepareDlg.wxs ^
              ProgressDlg.wxs ^
              ResumeDlg.wxs ^
              UserExit.wxs ^
              VerifyReadyDlg.wxs ^
              WaitForCostingDlg.wxs ^
              WelcomeDlg.wxs ^
              WixUI_InstallDir.wxs ^
              -dlicenseRtf="License.rtf" ^
              -dbannerBmp=.\bitmaps\bannrbmp.bmp ^
              -ddialogBmp=.\bitmaps\dlgbmp.bmp ^
              -dexclamationIco=.\bitmaps\exclamic.ico ^
              -dinfoIco=.\bitmaps\info.ico ^
              -dnewIco=.\bitmaps\New.ico ^
              -dupIco=.\bitmaps\Up.ico ^
              -dprinteulaDll=..\Helper.dll

lit.exe -nologo -out wixui.wixlib ^
                    BrowseDlg.wixobj ^
                    CancelDlg.wixobj ^
                    Common.wixobj ^
                    DiskCostDlg.wixobj ^
                    ErrorDlg.wixobj ^
                    ErrorProgressText.wixobj ^
                    ExitDialog.wixobj ^
                    FatalError.wixobj ^
                    FilesInUse.wixobj ^
                    InstallDirDlg.wixobj ^
                    LicenseAgreementDlg.wixobj ^
                    MaintenanceTypeDlg.wixobj ^
                    MaintenanceWelcomeDlg.wixobj ^
                    MsiRMFilesInUse.wixobj ^
                    OutOfDiskDlg.wixobj ^
                    OutOfRbDiskDlg.wixobj ^
                    PrepareDlg.wixobj ^
                    ProgressDlg.wixobj ^
                    ResumeDlg.wixobj ^
                    UserExit.wixobj ^
                    VerifyReadyDlg.wixobj ^
                    WaitForCostingDlg.wixobj ^
                    WelcomeDlg.wixobj ^
                    WixUI_InstallDir.wixobj
