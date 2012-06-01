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

