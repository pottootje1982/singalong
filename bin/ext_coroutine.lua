local function yield(...)
  if coroutine.running() then
    coroutine.yield(...)
  end
end

coroutine.wait = function(...)
  yield(...)
end

coroutine.waitFunc = function(func, ...)
  while not func() do
    yield(...)
  end
end

coroutine.waitTicks = function(ticks, ...)
  local i = 0
  local waitTicks = func
  local func = function()
    i = i + 1
    return i >= waitTicks
  end

  coroutine.waitFunc(func, ...)
end
