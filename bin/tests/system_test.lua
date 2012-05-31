
TestSystem = {}

function TestSystem:testGetExecutablePath()
  local exePath = system.getExecutablePath()
  local query = [[bin]]
  local match = exePath:match(query)
  assertEquals(match, query)
end
