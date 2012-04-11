require 'lfs'
require 'helpers'
require 'misc'

local args = {...}
local miktexDir = [[c:\temp\miktex2]]
local vsCompilerLocation = string.format([[%s..\IDE]], os.getenv('VS90COMNTOOLS') or os.getenv('VS80COMNTOOLS'))
WIX_LOCATION = string.format([[%s\bin]], os.getenv('WIX') or [[C:\Program Files (x86)\Windows Installer XML v3.5]])
local luaLocation = os.getenv('LUA_DEV') or [[E:\Program Files\Lua 5.1]]
checkOutDir = [[C:\tmp\singalong]]
local relSlnPath = [[source\main\main.sln]]

local noCheckout = table.find(args, 'nocheckout') ~= nil
local nobuild = table.find(args, 'nobuild') ~= nil
---[=[
if lfs.attributes(checkOutDir) then
  print(string.format('Do you want to remove target dir %q?', checkOutDir))
  local ans = io.read('*l')
  if ans:lower():match('^y') then
    print(string.format('Removing dir %q', checkOutDir))
    assert(execute(string.format([[rd /s /q %q]], checkOutDir)))
  else
    noCheckout = true
  end
end
--]=]

--------------- Checking out ---------------
---[=[
if not noCheckout then
  print(string.format('Checking out repos to %q...', checkOutDir))
  local res = execute([[svn export file://iomega-10d667/activefolders/ftp/svn/SingAlonG %q]], checkOutDir)
end
--]=]

if not nobuild then
  --------------- Building App ---------------
  ---[=[
  print(string.format('Building application %s\%s...', checkOutDir, relSlnPath))
  res = executePath(vsCompilerLocation, [[devenv "%s\%s" /Project singalong /Build Release]], checkOutDir, relSlnPath)
  --]=]

  --------------- Compiling lua files ---------------
  ---[=[
  print(string.format('Compiling lua files...'))

  res = executePath(luaLocation, [[luac "%s\bin\*.lua"]], checkOutDir)
  for file in lfs.dir(checkOutDir .. [[\bin]]) do
    if file:find('.lua') then
      executePath(luaLocation, [[luac -o "%s\bin\%s" "%s\bin\%s"]], checkOutDir, file, checkOutDir, file)
    end
  end
  --]=]
end

---[=[
--------------- Build WixUI -------------
local installerDir = lfs.currentdir()
local binDir = string.format([[%s\bin]], checkOutDir)
print(string.format('Building installer...'))
dofile [[ui\build.lua]]

--------------- Generate WXS files ------------
local candleFiles=string.format([["%s\singalong.wxs" "%s\bin.wxs"]], installerDir, installerDir)
local lightFiles=string.format([["%s\singalong.wixobj" "%s\bin.wixobj"]], installerDir, installerDir)

executePath(WIX_LOCATION, [[heat dir %s -cg binGroup -dr INSTALLDIR -nologo -gg -sfrag -sreg -var var.binDir -out "%s\bin.wxs"]], binDir, installerDir)

-- Add file association
---[=[
addStringAfterFile('bin.wxs', 'singalong.exe', [[
                    <ProgId Id='SinGaLonG.singfile' Description='SinGaLonG playlist file'>
                      <Extension Id='sing' ContentType='application/sing'>
                        <Verb Id='open' Command='Open' Target='[!fil4C32D3BEBCD2AFF5B5E1E0524682304A]' Argument='"%%1"' />
                      </Extension>
                    </ProgId>
]])
--]=]

--------------- Compile WXS files ---------------
executePath(WIX_LOCATION, [[candle -nologo -o %s\ %s -dbinDir="%s"]], installerDir, candleFiles, binDir)
--]=]
---[=[

--------------- Build MSI ---------------
-- We suppress errors LGHT1055 and LGHT1076 here because of a Microsoft-fuckup with the MSM's we include.
-- See http://blogs.msdn.com/astebner/archive/2007/02/13/building-an-msi-using-wix-v3-0-that-includes-the-vc-8-0-runtime-merge-modules.aspx
executePath(WIX_LOCATION, [[light -sw1055 -sw1076 -out %s\singalong.msi %s %s\ui\wixui.wixlib -loc %s\ui\WixUI_en-us.wxl -ext WixUtilExtension]], installerDir, lightFiles, installerDir, installerDir)
--]=]
