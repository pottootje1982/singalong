string.count = function(str, occurrence)
  local count = 0
  for i, v in str:gmatch(occurrence) do
    count = count + 1
  end
  return count
end

string.equals = function(str1, str2)
  if str1 and str2 then
    return str1:lower() == str2:lower()
  else
    return str1 == str2
  end
end

string.isStringEmptyOrSpace = function(str)
  return not str or str:match('^[%s%c]*$')
end
