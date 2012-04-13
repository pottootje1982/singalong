// singalong.cpp : Defines the entry point for the application.
//

#include "global.h"
#include "singalong.h"
#include "lua_system.h"
#include "lua_libharu.h"
#include "lua_libharupage.h" 
#include "clipboard.h"
#include <iostream>

#define USE_IUP 1

extern "C" {

#if USE_IUP
#include "iup.h"
#include "iuplua.h"
#include "iupluaim.h"
#include "iupluacontrols.h"
#include "cd.h"
#include "cdlua.h"
#include "cdluaiup.h"
#include "im.h"
#include "im_image.h"
#include "imlua.h"
#endif

#include "lfs.h"
#include "..\lmarshal\lmarshal.h"
#include "lpack.h"
#include "luasocket.h"
#include "mime.h"
}

#include <conio.h>
#include <string>

static int traceback (lua_State *L) {
  if (!lua_isstring(L, 1))  /* 'message' not a string? */
    return 1;  /* keep it intact */
  lua_getfield(L, LUA_GLOBALSINDEX, "debug");
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return 1;
  }
  lua_getfield(L, -1, "traceback");
  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 2);
    return 1;
  }
  lua_pushvalue(L, 1);  /* pass error message */
  lua_pushinteger(L, 2);  /* skip this function and traceback */
  lua_call(L, 2, 1);  /* call debug.traceback */
  return 1;
}


static int docall (lua_State *L, int narg, int clear) {
  int status;
  int base = lua_gettop(L) - narg;  /* function index */
  lua_pushcfunction(L, traceback);  /* push traceback function */
  lua_insert(L, base);  /* put it under chunk and args */
  status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
  lua_remove(L, base);  /* remove traceback function */
  /* force a complete garbage collection in case of errors */
  if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
  return status;
}

void close( lua_State * L ) 
{
#if USE_IUP
  iuplua_close(L);
#endif
  lua_close(L);
}

int main(int argc, char ** argv)
{
  lua_State *L = lua_open();

  luaL_openlibs(L);

#if USE_IUP
  iuplua_open(L);
  cdlua_open(L);
  cdluaiup_open(L);

  iupkey_open(L);
  iupimlua_open(L);
  IupImageLibOpen ();
  iupcontrolslua_open(L);
  imlua_open(L);
  imlua_open_process(L);
#endif

  luaopen_pack(L);
  luaopen_lfs(L);
  luaopen_marshal(L);
  luaopen_mime_core(L);
  luaopen_socket_core(L);

  pdfdoc_register(L);
  pdfpage_register(L);
  clipboard_register(L);
  luaopen_system(L);

#if _DEBUG 
  lua_pushboolean(L, true);
  lua_setfield(L, LUA_GLOBALSINDEX, "_DEBUG");
#endif
  
  char luaFile[512] = "";
  char playlistFile[512] = "";
  int beginIndex = 1;
  if (argc > 1)
  {
    int strl = strlen(argv[1]);
    bool isLuaFile = strcmp(&argv[1][strl-4], ".lua") == 0;
    if (isLuaFile)
    {
      beginIndex = 2;
      strcpy_s(luaFile, sizeof(luaFile), argv[1]);
    }
    else if (strcmp(&argv[1][strl-5], ".sing") == 0
      || strcmp(&argv[1][strl-4], ".m3u") == 0
      || strcmp(&argv[1][strl-4], ".txt") == 0)
    {
    }
  }
  if (!luaFile[0])
  {
    lua_pushboolean(L, true);
    lua_setfield(L, LUA_GLOBALSINDEX, "APPLOADED");
    strcpy_s(luaFile, sizeof(luaFile), "main.lua");
  }
    
  int temp_int = luaL_loadfile(L,luaFile);

  int returnval = 0;
  if (temp_int)
  {
    const char *error = lua_tostring(L, -1);
    printf("Error in file: \"%s\"\n", luaFile);
    printf("%s\n", error);
    returnval = 1;
  }
  else
  {
    const char *error;

    for (int i = beginIndex; i < argc; i++)
      lua_pushstring(L, argv[i]);

    if (docall(L,argc-beginIndex,0))
    {
      error = lua_tostring(L, -1);
      std::cout << error;
    }
  }
  close(L);

  return returnval;
}

#ifndef USE_IUP | WINDOWS
int WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    int nCmdShow
)
{
  main(__argc, __argv);
  return 0;
}
#endif