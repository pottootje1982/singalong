module('app', package.seeall)

require 'misc'
require 'class'

local appInstance

class 'application'

function application:application()
  self.coroutines = {}
end

function application:addCo(func, resumeFunc, endFunc, errorCallback)
  if not APPLOADED then func() return end
  local co = coroutine.create(func)
  table.insert(self.coroutines, {co=co, resume=resumeFunc, endFunc = endFunc, errorCallback = errorCallback})
  return co
end

function application:removeCo(co)
  local i, entry = table.find(self.coroutines, function(i,entry) return entry.co == co end)
  if i then
    table.remove(self.coroutines, i)
    if entry.endFunc then
      entry.endFunc()
    end
  end
end

function application:waitToFinish(co)
  print(table.find(self.coroutines, function(i,entry) return entry.co == co end))
  while table.find(self.coroutines, function(i,entry) return entry.co == co end) ~= nil do
    self:tick()
  end
end

function application:tick()
  local routinesToRemove = {}
  for i, entry in ipairs(self.coroutines) do
    if coroutine.status(entry.co) ~= 'dead' then
      local res = {coroutine.resume(entry.co)}
      if not res[1] then
        local handled
        if entry.errorCallback then handled = entry.errorCallback(res[2]) end
        if not handled then iup.Message('Warning', string.format('Error in coroutine %d: %s', i, res[2])) end
        table.insert(routinesToRemove, entry.co)
      end

      -- the coroutine could've been killed in the coroutine.resume above
      if entry.resume and coroutine.status(entry.co) ~= 'dead' then
        -- First argument contains only bool if there was error
        table.remove(res, 1)
        os.pcall(function()
          entry.resume(unpack(res))
        end)
      end
    else
      table.insert(routinesToRemove, entry.co)
    end
  end
  for i, co in ipairs(routinesToRemove) do
    self:removeCo(co)
  end
  -- iup.SetIdle() will consume all processor resources
  -- when sleep is not here
  system.sleep(1)
end

appInstance = application()

function addCo(...)
  return appInstance:addCo(...)
end

function removeCo(co)
  appInstance:removeCo(co)
end

function waitToFinish(co)
  appInstance:waitToFinish(co)
end

iup.SetIdle(function()
  appInstance:tick()
end)
