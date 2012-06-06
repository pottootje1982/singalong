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
  local res, mess
  local succ, mess = pcall(function()
    res = table.unmarshal(os.read(fn, true))
  end)
  if succ then
    return res
  else
    print(mess)
  end
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

local function compare(operand, i, entry)
  if type(operand) == 'function' then
    if operand(i, entry) then return i, entry end
  else
    if entry == operand then return i, entry end
  end
end


table.find = function(tab, operand)
  for i, entry in pairs(tab) do
    if compare(operand, i, entry) then return i, entry end
  end
end

table.ifind = function(tab, operand, from)
  for i = from or 1, #tab do
    if compare(operand, i, tab[i]) then return i, tab[i] end
  end
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
  for i, v in pairs(tab1) do
    if type(v) == 'table' and type(tab2[i]) == 'table' then
      if not table.equals(v, tab2[i]) then return false end
    elseif v ~= tab2[i] then return false end
  end
  return true
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

table.removeDoubles = function(tab, func)
  for i = 1, #tab do
    local entry = tab[i]
    local foundI, foundEntry = true, nil
    local compareFunc = function(i,v)
      if func then return func(entry, v)
      else return v == entry end
    end
    while foundI and tab[i+1] do
      foundI, foundEntry = table.ifind(tab, compareFunc, i+1)
      if foundI then
        table.remove(tab, foundI)
      end
    end
  end
  return tab
end

table.areEquals = function(tab1, tab2)
  assert(table.equals(tab1, tab2))
end
