#include "lua_system.h"
#include <iostream>
#include <direct.h>

std::string executablePath;

void setExecutablePath(char* charPath)
{
  std::string path(charPath);
  int index = path.find_last_of('\\');
  path = path.substr(0, index + 1);
  executablePath = path;
  if (executablePath == "")
  {
    executablePath = _getcwd( NULL, 0 );
  }
}

int lua_getExecutablePath(lua_State *L)
{
  lua_pushstring(L, executablePath.c_str());
  return 1;
}

static luaL_Reg system_func[] = {
  {"sleep",             lua_sleep},
  {"getExecutablePath", lua_getExecutablePath},
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


