string.count = function(str, occurrence)
  local count = 0
  for i, v in str:gmatch(occurrence) do
    count = count + 1
  end
  return count
end