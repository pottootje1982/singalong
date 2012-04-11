args = {...}
local localPath = args[1]               or [[C:\Users\Wouter\Documents]]
local networkPath = args[2]             or [[\\192.168.2.1\partition1]]
local fn = args[3]                      or [[CD's en DVD's.CTF]]
local program = args[4]                 or [[WhereIsIt.exe]]
localPath = localPath .. [[\]]
networkPath = networkPath .. [[\]]

require "lfs"

local function synchronize(localPath, networkPath,fn)
	localAttribs = lfs.attributes (localPath .. fn)
	networkAttribs = lfs.attributes(networkPath .. fn)
	if localAttribs or networkAttribs then
		if (not localAttribs or (networkAttribs and (networkAttribs.modification > localAttribs.modification))) then
			print('Copying from network to local...')
			os.execute([[xcopy/y "]] .. networkPath .. fn .. [[" "]] .. localPath .. [["]])
		end
		if (not networkAttribs or (localAttribs and (networkAttribs.modification < localAttribs.modification))) then
			print('Copying from local to network...')
			os.execute([[xcopy/y "]] .. localPath .. fn .. [[" "]] .. networkPath .. [["]])
		end
	else
		print('file not present at any of the specified paths')
	end
end

synchronize(localPath, networkPath, fn)
lfs.chdir ([[e:\Program Files\WhereIsIt\]])
os.execute (program .. [[ "]] .. localPath .. fn .. [["]])
synchronize(localPath, networkPath, fn)
