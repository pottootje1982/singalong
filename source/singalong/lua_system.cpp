#include "lua_system.h"

static luaL_Reg system_func[] = {
  {"sleep",             lua_sleep},
  {"setIcon",           lua_setIcon},
  {"createProcess",     lua_createProcess},
  {"shellExecute",      lua_shellExecute},
  {"shellExecuteWait",  lua_shellExecuteWait},
  {NULL,        NULL}
};

int luaopen_system(lua_State *L)
{
  luaL_register(L, "system", system_func);
  return 0;
}


