function verify(succ, mess)
  if not succ then
    local debugMessage = '\n' .. debug.traceback()
    iup.Message('Error', (mess or '') .. debugMessage)
    assert(succ, mess)
  end
end

os.format_bare_file = function(artist, title, ext)
  return string.format([[%s.%s]], replace(artist .. ' - ' .. title, fileReplacements), ext)
end

os.format_file = function(ext, search_site, mp3)
  local artist, title = mp3.artist, mp3.title
  assert(artist and title and search_site, "One of the parameters artist, title or search_site is nil!")
  assert(search_site.site, 'Invalid search site')
  assert(ext, 'No extension given')
  local res = F(LYRICS_DIR, search_site.site, os.format_bare_file(artist, title, ext))
  return res
end

os.getFileWithoutExt = function(fn)
  return fn:match('^(.+)(%..+)$')
end

os.createDir = function(dir)
  dir = dir:match([[^(.-)\*$]])
  if not lfs.attributes(dir) then
    verify(lfs.mkdir(dir))
  end
end

os.delete = function(fn)
  if lfs.attributes(fn) then
    os.execute('del /f/q ' .. fn)
  end
end

os.copy = function(fn1, fn2)
  local command = string.format([[xcopy /q/y "%s" "%s"]], fn1, fn2)
  print(command)
  os.execute(command)
end

os.getPath = function(fn)
  return fn:match('^(.-)\\+[^\\]+$')
end

os.exists = function(fn)
  if fn then
    f = io.open(fn, 'r')
    if f then
      f:close()
      return true
    else
      return false
    end
  else
    return false
  end
end

os.isFileWritable = function(fn)
  return fn and (io.open(fn, 'w+') ~= nil)
end

os.read = function(fn, binary)
  file = io.open(fn, binary and 'rb' or 'r')
  if file then
    content = file:read('*a')
    file:close()
    return content
  else
    return file
  end
end

os.writeTo = function(fn, content, binary)
  file = io.open(fn, binary and 'wb+' or 'w+')
  assert(file:write(content))
  file:close()
end

os.shellExecute = function(fileName, command, action, dir)
  if command == 'html' then -- in case an url needs to be opened
    if fileName and fileName ~= '' then
      system.shellExecuteWait(fileName, '', action)
    end
  else -- in case an file has to be opened
    if command or os.exists(fileName) then
      if action == 'select' then
        local selectCommand = string.format('/select,"%s"', fileName)
        system.shellExecuteWait('explorer.exe', selectCommand, 'open')
      else
        system.shellExecuteWait(command or 'explorer.exe', fileName, 'open', dir)
      end
    else
      iup.Message('Warning', string.format([["%s" cannot be opened!]], fileName))
    end
  end
end

os.iterateDir = function(path, dirFunc, fileFunc)
  path = path .. [[\]]
  for file in lfs.dir(path) do
    if not(file == '.' or file == '..') then
      file = path .. file
      local attribs = lfs.attributes(file)
      local mode = attribs and attribs.mode
      if mode == 'file' and fileFunc then
        fileFunc(file)
      elseif mode == 'directory' then
        os.iterateDir(file, dirFunc, fileFunc)
      end
    end
  end
  if dirFunc then
    return dirFunc(path)
  end
end

os.removeDir = function(path, doNotRemoveDirs)
  local dirFunc
  if not doNotRemoveDirs then
    dirFunc = function(path)
      return lfs.rmdir(path)
    end
  end

  os.iterateDir(path, dirFunc, function(file) os.remove(file) end)
end

os.removeFileType = function(path, ext)
  os.iterateDir(path, dirFunc,
    function(file)
      if os.getExtension(file) == ext then os.remove(file) end
    end)
end

os.gatherFiles = function(path, ext)
  local res = {}
  os.iterateDir(path, nil,
    function(file)
      if os.getExtension(file) == ext then
        table.insert(res, file)
      end
    end)
  return res
end

os.getExtension = function(file)
  return file:match('%.([^%.]+)$')
end

os.calcTime = function(name, funcToTime)
  local start = os.clock()
  funcToTime()
  print(string.format("Function %s took %f seconds to complete", name, os.clock() - start))
end

os.checkIfFileExists = function(dir, file, extraInfo)
  if not lfs.attributes(string.format('%s\\%s', dir, file)) then
    iup.Message('Warning', string.format([["%s" doesn't exist in directory "%s"!%s]], file, dir, extraInfo or ''))
    return false
  else
    return true
  end
end

