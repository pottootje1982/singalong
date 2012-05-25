#pragma once

#include "global.h"

void setExecutablePath(char* charPath);

int lua_sleep(lua_State *L);
int lua_getExecutablePath(lua_State *L);
int lua_setIcon(lua_State *L);
int lua_shellExecute(lua_State *L);
int lua_shellExecuteWait(lua_State *L);
int lua_createProcess(lua_State *L);

int luaopen_system(lua_State *L);
