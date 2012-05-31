module('misc', package.seeall)

require 'lfs'

-- constitutes a path from strings
_G.F = function(...)
  return table.concat(arg, [[\]])
end

_G._ = function(str)
    -- ^     $        (       )       %      .       [      ]         *        +       -       ?
    return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", '%%%1')
end

_G.getPdfGenerator = function()
  -- pdfGenerator can be 'Singalong pdf' hence the gsub
  return require(config.pdfGenerator:gsub(' ', ''))
end

_G.getFontColor = function(str)
  local r, g, b = str:match('(%d+) (%d+) (%d+)')
  return tonumber(r)/255,tonumber(g)/255,tonumber(b)/255
end

_G.getSize = function(str)
  local w, h = str:match('(%d+)x(%d+)')
  return tonumber(w), tonumber(h)
end

os.getFileWithoutExt = function(fn)
  return fn:match('^(.+)(%..+)$')
end

os.createDir = function(dir)
  dir = dir:match([[^(.-)\*$]])
  if not lfs.attributes(dir) then
    misc.verify(lfs.mkdir(dir))
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

table.saveToFileText = function(fn, tab, prefix)
  local content = ''

  local function p(t,tabs)
    content = content .. tabs .. "{\n"

    for k,v in pairs(t) do
      content = content .. tabs

      k = (type(k) == "string") and ('"' .. k .. '"') or k
      if type(v) == "string" then
        content = content .. string.format('  [%s] = [=[%s]=],\n', k, v)
      elseif type(v) == "number" then
        content = content .. string.format("  [%s] = %f,\n", k, v)
      elseif type(v) == "table" then
        content = content .. string.format("  [%s] = \n", k, v)
        assert(t, "Table is nil! Key: " .. tostring(k) .. ", Value: " .. tostring(v))
        p(v, tabs.."  ")
        content = content .. ",\n"
      else
        -- try userdata __tostring
        content = content .. string.format("  [%s] = %s,\n", k, tostring(v))
      end
    end
    content = content .. tabs.."}"
  end

  p(tab, "")

  os.writeTo(fn, (prefix or 'return ') .. content)
end

table.loadFromFile = function(fn)
  local res
  local succ = pcall(function()
    res = table.unmarshal(os.read(fn, true))
  end)
  if succ then return res end
end

table.saveToFile = function(fn, tab, prefix)
  os.writeTo(fn, table.marshal(tab), true)
end

table.isEmpty = function(tab)
  return next(tab) == nil
end

table.print = function(t, prefix, recurse)
  recurse = recurse == nil and true or false
  local oldPrefix = prefix or ''
  prefix = oldPrefix .. '  '
  print(oldPrefix .. '{')
  for i,v in pairs(t or {}) do
    if type(v) == 'table' then
      print(prefix .. i .. ' = ')
      if recurse and not tostring(i):match('^_') then
        table.print(v, prefix)
      else
        print(prefix .. tostring(v))
      end
    else
      print(prefix .. tostring(i) .. '=' .. tostring(v) .. ',')
    end
  end
  print(oldPrefix .. '}')
end

function table.filter(tab, func, iterator)
  local result = {}
  iterator = iterator or pairs
  for i, v in iterator(tab) do
    if func(i, v) then
      table.insert(result, v)
    end
  end
  return result
end

function table.ifilter(tab, func)
  return table.filter(tab, func, ipairs)
end

table.find = function(tab, key, iterator)
  for _, entry in (iterator or pairs)(tab) do
    if type(key) == 'function' then
      if key(_, entry) then return _, entry end
    else
      if entry == key then return _, entry end
    end
  end
  return nil
end

table.ifind = function(tab, key)
  return table.find(tab, key, ipairs)
end

table.copy = function(tab, iterator)
  local res = {}
  for i, v in (iterator or pairs)(tab) do
    table.insert(res, v)
  end
  return res
end

table.icopy = function(tab)
  return table.copy(tab, ipairs)
end

table.merge = function(tab1, tab2, at, iterator)
  local res = table.copy(tab1, iterator)
  at = at or (#res + 1)
  for i, v in (iterator or pairs)(tab2) do
    table.insert(res, at or (#res + 1), v)
    at = at + 1
  end
  return res
end

table.imerge = function(tab1, tab2, at)
  return table.merge(tab1, tab2, at, ipairs)
end

table.equals = function(tab1, tab2)
  if #tab1 ~= #tab2 then return false end
  for i, v in ipairs(tab1) do
    if v ~= tab2[i] then return false end
  end
  return true
end

os.calcTime = function(name, funcToTime)
  local start = os.clock()
  funcToTime()
  print(string.format("Function %s took %f seconds to complete", name, os.clock() - start))
end

-- Make tables zero based for use in iup.GetParam (combobox selections are zero based there)
-- Note that you have to use table.find for the resulting array
table.makeZeroBased = function(tab)
  for i, v in ipairs(tab) do
    tab[i-1] = tab[i]
  end
  tab[#tab] = nil
  return tab
end

-- Concat table zero based (for use in iup.GetParam)
table.zeroConcat = function(tab, delimiter)
  local res = ''
  for i = 0, #tab do
    res = res .. delimiter .. tab[i]
  end
  return res .. delimiter
end

os.checkIfFileExists = function(dir, file, extraInfo)
  if not lfs.attributes(string.format('%s\\%s', dir, file)) then
    iup.Message('Warning', string.format([["%s" doesn't exist in directory "%s"!%s]], file, dir, extraInfo or ''))
    return false
  else
    return true
  end
end

string.count = function(str, occurrence)
  local count = 0
  for i, v in str:gmatch(occurrence) do
    count = count + 1
  end
  return count
end

coroutine.waitFor = function(func)
  local function yield(...)
    if coroutine.running() then
      coroutine.yield(...)
    end
  end

  if func and type(func) == 'number' then
    local i = 0
    local waitTicks = func
    func = function()
      i = i + 1
      return i >= waitTicks
    end
  end

  if func then
    while not func() do
      yield()
    end
  else
    yield()
  end
end

function verify(succ, mess)
  if not succ then
    local debugMessage = '\n' .. debug.traceback()
    iup.Message('Error', (mess or '') .. debugMessage)
    assert(succ, mess)
  end
end
