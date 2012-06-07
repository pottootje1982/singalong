local function yield(...)
  if coroutine.running() then
    coroutine.yield(...)
  end
end

coroutine.wait = function(...)
  yield(...)
end

coroutine.waitFunc = function(func, ...)
  repeat
    local res = {func()}
    yield(unpack(res))
  until res[1]
end

coroutine.waitTicks = function(ticks, ...)
  local i = 0
  local waitTicks = func
  local func = function()
    i = i + 1
    return i >= ticks
  end

  while not func() do
    yield(...)
  end
end
