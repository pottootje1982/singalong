require 'class'

class 'event'

function event:event()
  self.subscribers = {}
  return self
end

function event:subscribe(func)
  local subscriber = {func = func}
  table.insert(self.subscribers, subscriber)
  return subscriber
end

function event:unsubscribe(subscriber)
  local i = table.ifind(self.subscribers, subscriber)
  if i and i > 0 then
    table.remove(self.subscribers, i)
  end
end

function event:fire(...)
  for i, subs in ipairs(self.subscribers) do
    subs.func(...)
  end
end
