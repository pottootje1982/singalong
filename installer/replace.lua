dofile 'helpers.lua'

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- In bin.wxs
--  - Add Start-menu shortcut for client
--  - Add Start-menu shortcut for server
--  - Add Start-menu shortcut for rlaunch
local binInsertions = {
	["$(var.BinDir)\\footprint_client_ui.exe"] = 
--	%2 are a sequence of spaces here
[=[
%2        <Shortcut Id="startmenuLumoClient" Directory="ProgramMenuDir"
%2            Name="$(var.ProductType) Client" WorkingDirectory='INSTALLDIR' Icon="Lumo.EXE" IconIndex="0" Advertise="yes"/>
%2    </File>
%2    <RemoveFolder Id='ClientRemoveShortcut' On='uninstall' Directory='ProgramMenuDir'/>]=],

	["$(var.BinDir)\\footprint_server_ui.exe"] = 
[=[
%2        <Shortcut Id="startmenuLumoServer" Directory="ProgramMenuDir" 
%2            Name="$(var.ProductType) Server" WorkingDirectory='INSTALLDIR' Icon="Lumo.EXE" IconIndex="0" Advertise="yes"/>
%2    </File>
%2    <RemoveFolder Id='ServerRemoveShortcut' On='uninstall' Directory='ProgramMenuDir'/>]=],

	["$(var.BinDir)\\footprint_rlaunch.exe"] = 
[=[
%2    </File>
%2    <RegistryValue Id='LumoRegLauncher' Root='HKLM' Key='Software\Microsoft\Windows\CurrentVersion\Run' Name='Lumo Scenario Remote Launcher'
%2        Action='write' Type='string' Value='[INSTALLDIR]bin\footprint_rlaunch.exe' />]=],

	
}
for search, insert in pairs(binInsertions) do
	addStringAfterFile('bin.wxs', search, insert)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- in aar.wxs
-- Add Start-menu shortcut for aar-app
-- Do some extension registration to link aar file extension to aar-app
local aarInsertions = 
{
	["$(var.AarDir)\\bin\\footprint_aar.exe"] = 
[=[
%2        <Shortcut Id="startmenuLumoAAR" Directory="ProgramMenuDir"
%2            Name="$(var.ProductType) After Action Review" WorkingDirectory='INSTALLDIR' Icon="Aar.EXE" IconIndex="0" Advertise="yes"/>
%2    </File>
%2    <RemoveFolder Id='AARRemoveShortcut' On='uninstall' Directory='ProgramMenuDir'/>
%2    <ProgId Id='footprint_aar.aarfile' Description='Lumo AAR file' Icon="%4" IconIndex="0">
%2        <Extension Id='aar' ContentType='application/aar'>
%2            <Verb Id='open' Command='Open' TargetFile='%4' Argument='"%%1"' />
%2        </Extension>
%2    </ProgId>
%2    <ProgId Id='footprint_aar.aarzipfile' Description='Lumo AAR compressed file' Icon="%4" IconIndex="0">
%2        <Extension Id='aarzip' ContentType='application/aarzip'>
%2            <Verb Id='open' Command='Open' TargetFile='%4' Argument='"%%1"' />
%2        </Extension>
%2    </ProgId>]=],
}
for search, insert in pairs(aarInsertions) do
	addStringAfterFile('aar.wxs', search, insert)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- In doc.wxs:
--  add Shortcut-tag if file 'drivingsim_manual_en.pdf' is encountered
local docInsertions = {
	["$(var.DocDir)\\drivingsim_manual_en.pdf"] = 
[=[
%2        <Shortcut Id="startmenuManual" Directory="ProgramMenuDir" Name="DrivingSim Manual" Advertise="yes" Icon="Manual.ico" IconIndex="0"/>
%2    </File>]=],
}
for search, insert in pairs(docInsertions) do
	addStringAfterFile('doc.wxs', search, insert)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- insert in bin.wxs and aar.wxs in the beginning 
local varInclusions = {
	['(<?xml version=".*?>)'] =
[=[%1
<?include vars.wxs ?>
]=]
}
for i, fileName in pairs({'bin.wxs', 'aar.wxs'}) do
	replaceStringInFile(fileName, varInclusions)
end