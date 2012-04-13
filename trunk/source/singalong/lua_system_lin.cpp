#include "lua_system.h"
#include "Resource.h"

#ifndef WIN32

int lua_sleep(lua_State *L)
{
  return 0;
}

int lua_setIcon(lua_State *L)
{
  return 0;
}

int lua_shellExecute(lua_State *L)
{
  return 1;
}

int lua_shellExecuteWait(lua_State *L)
{
  return 0;
}

int lua_createProcess(lua_State *L)
{
  return 0;
}

#endif
