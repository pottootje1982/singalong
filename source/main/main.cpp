#include <windows.h>

#define _WIN32

extern "C" {
#include <lua.h>
#include "../luasource/lauxlib.h"
#include "../luasource/lualib.h"
#include "../cd/include/cd.h"
#include "../cd/include/cdlua.h"
#include "../iup/include/iup.h"
#include "../iup/include/iuplua.h"
}

int main (int argc, char **argv) 
{
	
	lua_State *L = lua_open();

	luaL_openlibs(L);
	cdlua_open(L);
	iuplua_open(L);

	int temp_int = luaL_loadfile(L,"test.lua");
	if (temp_int)
	{
		printf("cannot load file test.lua.");
		lua_close(L);
		return 1;
	}
	else
	{
		printf("Succesfully loaded test.lua");
		if (lua_pcall(L,0,0,0))
			printf(lua_tostring(L, -1));
		lua_close(L);
	}

	return 0;
}