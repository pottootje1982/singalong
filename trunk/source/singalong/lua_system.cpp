#include "lua_system.h"
#include "Resource.h"

#ifdef WIN32

int lua_sleep(lua_State *L)
{
  Sleep(lua_tointeger(L,1));
  return 0;
}

int lua_setIcon(lua_State *L)
{
  HINSTANCE hInstance = (HINSTANCE)lua_touserdata(L, 1);
  // Find HWND on basis of its title
  HWND hMainWnd = FindWindowA( NULL, lua_tostring(L, 2) );
  HICON hIcon =  ::LoadIcon(hInstance, MAKEINTRESOURCE(IDI_SINGALONG));
  CWnd *hWnd = CWnd::FromHandle(hMainWnd);
  HICON hResIcon = hWnd->SetIcon(hIcon, 0);
  return 0;
}

int lua_shellExecute(lua_State *L)
{
  const char* command = lua_tostring(L,1);
  const char* args = lua_tostring(L,2);
  const char* action = lua_tostring(L, 3);

  HINSTANCE r = ShellExecute(NULL, action, command, strcmp(args, "") == 0 ? NULL : args, NULL, SW_SHOWNORMAL);
  DWORD e = GetLastError();

  lua_pushlightuserdata(L, (void*)r);
  return 1;
}

int lua_shellExecuteWait(lua_State *L)
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

int lua_createProcess(lua_State *L)
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


#endif