require 'misc'
require 'luaunit'
require 'event'

TestEvent = {}

local tickEvent = event()

local messages = {}

function TestEvent:testEvents()
  local subs1 = tickEvent:subscribe(function(mess)
    table.insert(messages, mess .. '1')
  end)
  local subs2 = tickEvent:subscribe(function(mess)
    table.insert(messages, mess .. '2')
  end)
  table.areEquals(tickEvent.subscribers, {subs1, subs2})
  tickEvent:fire('ouch')
  tickEvent:unsubscribe(subs1)
  table.areEquals(tickEvent.subscribers, {subs2})
  tickEvent:fire('bla')
  table.areEquals(messages, {'ouch1','ouch2', 'bla2'})
end
