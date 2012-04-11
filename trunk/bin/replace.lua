fileReplacements =
{
  -- " * / : < > ? \ |
  '[&"*/:<>?\|]+',               '',
}

repl_for_query =
{
  '^(.*)&(.*)$',                '%1',
  ' ',                          '+',
}

function replace(str, replacements, times)
  assert(str, 'No string given')
  for i = 1, #replacements, 2 do
    str = str:gsub(replacements[i], replacements[i+1], times)
  end
  assert(str, 'No result string could be calculated')
  return str
end
