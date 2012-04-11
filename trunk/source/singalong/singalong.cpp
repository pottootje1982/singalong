// singalong.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "singalong.h"
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

#include <mmsystem.h>
#include <conio.h>
#include <string>
#include <vector>
#include <algorithm>

static int lua_play(lua_State *L)
{
  const char *test = lua_tostring(L,1);
  BOOL bla = PlaySound(test,NULL,SND_FILENAME|SND_ASYNC);//PLAY WAV SOUND ONCE

  Sleep(lua_tointeger(L,2));

  return 0;
}

static int lua_sleep(lua_State *L)
{
  Sleep(lua_tointeger(L,1));
  return 0;
}

template <class T> float edit_distance(const T& s1, const T& s2)
{
  const size_t len1 = s1.size(), len2 = s2.size();
  std::vector<std::vector<unsigned int> > d(len1 + 1, std::vector<unsigned int>(len2 + 1));

  d[0][0] = 0;
  for(unsigned int i = 1; i <= len1; ++i) d[i][0] = i;
  for(unsigned int i = 1; i <= len2; ++i) d[0][i] = i;

  for(unsigned int i = 1; i <= len1; ++i)
    for(unsigned int j = 1; j <= len2; ++j)

      d[i][j] = min( min(d[i - 1][j] + 1,d[i][j - 1] + 1),
      d[i - 1][j - 1] + (s1[i - 1] == s2[j - 1] ? 0 : 1) );
  return 1-d[len1][len2]/(float)(max(len1, len2));
}

static int lua_levenshtein(lua_State *L)
{
  std::string str1 = lua_tostring(L, 1);
  std::string str2 = lua_tostring(L, 2);
  float res = edit_distance(str1, str2);
  lua_pushnumber(L, res);
  return 1;
}

static int lua_setIcon(lua_State *L)
{
  HINSTANCE hInstance = (HINSTANCE)lua_touserdata(L, 1);
  // Find HWND on basis of its title
  HWND hMainWnd = FindWindowA( NULL, lua_tostring(L, 2) );
  HICON hIcon =  ::LoadIcon(hInstance, MAKEINTRESOURCE(IDI_SINGALONG));
  CWnd *hWnd = CWnd::FromHandle(hMainWnd);
  HICON hResIcon = hWnd->SetIcon(hIcon, 0);
  return 0;
}

static int lua_shellExecute(lua_State *L)
{
  const char* command = lua_tostring(L,1);
  const char* args = lua_tostring(L,2);
  const char* action = lua_tostring(L, 3);

  HINSTANCE r = ShellExecute(NULL, action, command, strcmp(args, "") == 0 ? NULL : args, NULL, SW_SHOWNORMAL);
  DWORD e = GetLastError();

  lua_pushlightuserdata(L, (void*)r);
  return 1;
}

static int lua_shellExecuteWait(lua_State *L)
{
  const char* command = lua_tostring(L,1);
  const char* args = lua_tostring(L,2);
  const char* action = lua_tostring(L, 3);
  const char* dir = lua_tostring(L, 4);

  SHELLEXECUTEINFO lpExecInfo;
  lpExecInfo.cbSize  = sizeof(SHELLEXECUTEINFO);
  lpExecInfo.lpFile = command; // name of file that you want to execute/ print/ or open/ in your case Adobe Acrobat.
  lpExecInfo.fMask=SEE_MASK_DOENVSUBST|SEE_MASK_NOCLOSEPROCESS ;     
  lpExecInfo.hwnd = NULL;  
  lpExecInfo.lpVerb = action; // to open  program
  lpExecInfo.lpParameters = args; //  file name as an argument
  lpExecInfo.lpDirectory = dir;   
  lpExecInfo.nShow = SW_SHOW ;  // show command prompt with normal window size 
  lpExecInfo.hInstApp = (HINSTANCE) SE_ERR_DDEFAIL ;   //WINSHELLAPI BOOL WINAPI result;
  ShellExecuteEx(&lpExecInfo);

  //wait until a file is finished printing
  if(lpExecInfo.hProcess !=NULL)
  {
    ::WaitForSingleObject(lpExecInfo.hProcess, INFINITE);
    ::CloseHandle(lpExecInfo.hProcess);
  }

  return 0;
}

static int lua_createProcess(lua_State *L)
{
  STARTUPINFO si;
  PROCESS_INFORMATION pi;
  const char* command = lua_tostring(L,1);
  int res = CreateProcess(NULL, (LPSTR)command,
    NULL,           // Process handle not inheritable
    NULL,           // Thread handle not inheritable
    FALSE,          // Set handle inheritance to FALSE
    0,              // No creation flags
    NULL,           // Use parent's environment block
    NULL,           // Use parent's starting directory 
    &si,            // Pointer to STARTUPINFO structure
    &pi );

  return 0;
}

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

static luaL_Reg sound_func[] = {
    {"play",      lua_play},
    {NULL,        NULL}
};

static luaL_Reg system_func[] = {
    {"levenshtein",       lua_levenshtein},
    {"sleep",             lua_sleep},
    {"setIcon",           lua_setIcon},
    {"createProcess",     lua_createProcess},
    {"shellExecute",      lua_shellExecute},
    {"shellExecuteWait",  lua_shellExecuteWait},
    {NULL,        NULL}
};

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

  luaL_register(L, "sound", sound_func);
  luaL_register(L, "system", system_func);

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