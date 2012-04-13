#pragma once

#include "global.h"
#include "lua_system.h"

int lua_sleep(lua_State *L);
int lua_setIcon(lua_State *L);
int lua_shellExecute(lua_State *L);
int lua_shellExecuteWait(lua_State *L);
int lua_createProcess(lua_State *L);