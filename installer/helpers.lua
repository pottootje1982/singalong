function _(str)
  -- the following construct is needed because gsub only takes patterns, so we have to the escape magic characters
  -- ^$()%.[]*+-?
  return (string.gsub(str, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%0"))
end

function execute(str, ...)
  local command = string.format(str, ...)
  local res, mes = os.execute(command)
  assert(res == 0, string.format('Problem executing command %q, %s, %s', command, tostring(res), tostring(mes)))
  return res, mes
end

function executePath(path, str, ...)
  local oldDir = lfs.currentdir()
  assert(lfs.chdir(path), string.format('Path %q not found!', path))
  local res = execute(str, ...)
  lfs.chdir(oldDir)
  return res
end

local function openFile(fileName)
	file = io.open(fileName , "r" )
	if file then
		local content = file:read('*a')
		file:close()
		return content
	end
end

local function saveToFile(fileName, fileContent)
	local fileExport = io.open(fileName, "w")
	fileExport:write(fileContent)
	fileExport:close()
end

function replaceStringInFile(fileName, replacements)
	local fileContent = openFile(fileName)
	if fileContent then
		for search, replace in pairs(replacements) do
			fileContent, nrReplaced = string.gsub(fileContent, search, replace);
		end
		saveToFile(fileName, fileContent)
	end
end

-- function to add a string within a File entry (for example a shortcut)
function addStringAfterFile(fileName, search, insertString)
	local fileContent = openFile(fileName)
	if fileContent then
	
		-- %1 = beginning of Component entry + entire File entry minus />
		-- %2 = \n[%s]+ = sequence of spaces 
		-- %3 = [^\"]+ = componentID (search for 1 or more occurences of non-"-characters
		-- %4 = [^\"]+ = fileID
		
		search = "(\n([%s]+)" .. [=[<Component Id="([^\"]+)"[^\/]-<File Id="([^\"]+)" KeyPath="yes" Source="[^"]+]=] .. _(search) .. [=[" />)]=]
		local component, spaces, componentID = fileContent:match(search)
		insertString = "%1\n" .. insertString
		
		local nrReplaced
		fileContent, nrReplaced = string.gsub(fileContent, search, insertString);
		
		saveToFile(fileName, fileContent)
		-- return componentID so the ComponentRef can be optionally deleted
		return componentID
	end
end

function getFileID(fileName, search)
	local fileContent = openFile(fileName)
	if fileContent then
	
		-- %1 = beginning of Component entry + entire File entry minus />
		-- %2 = \n[%s]+ = sequence of spaces 
		-- %3 = [^\"]+ = componentID (search for 1 or more occurences of non-"-characters
		-- %4 = [^\"]+ = fileID
		
		search = "(\n([%s]+)" .. [=[<Component Id="([^\"]+)"[^\/]-<File Id="([^\"]+)" KeyPath="yes" Source="]=] .. _(search) .. [=[")]=]
		local component, spaces, componentID, fileID = fileContent:match(search)
		return fileID
	end
end

function remComponentRef(fileName, componentID)
	local fileContent = openFile(fileName)
	if fileContent and componentID then
		local componentref =  "\n[%s]+" .. _([[<ComponentRef Id="]]) .. componentID .. _([[" />]])
		print(componentref)
		local nrReplaced
		fileContent, nrReplaced = string.gsub(fileContent, componentref, '');
		print(nrReplaced)
		saveToFile(fileName, fileContent)
	end
end