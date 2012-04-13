#include "lua_system.h"
#include "Resource.h"

#include <string.h>
#include <vector>
#include <algorithm>


#ifdef WIN32

template <class T> float edit_distance(const T& s1, const T& s2)
{
  const size_t len1 = s1.size(), len2 = s2.size();
  std::vector<std::vector<unsigned int> > d(len1 + 1, std::vector<unsigned int>(len2 + 1));

  d[0][0] = 0;
  for(unsigned int i = 1; i <= len1; ++i) d[i][0] = i;
  for(unsigned int i = 1; i <= len2; ++i) d[0][i] = i;

  for(unsigned int i = 1; i <= len1; ++i)
    for(unsigned int j = 1; j <= len2; ++j)

      d[i][j] = std::min( std::min(d[i - 1][j] + 1,d[i][j - 1] + 1),
      d[i - 1][j - 1] + (s1[i - 1] == s2[j - 1] ? 0 : 1) );
  return 1-d[len1][len2]/(float)(std::max(len1, len2));
}

static int lua_levenshtein(lua_State *L)
{
  std::string str1 = lua_tostring(L, 1);
  std::string str2 = lua_tostring(L, 2);
  float res = edit_distance(str1, str2);
  lua_pushnumber(L, res);
  return 1;
}

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
  {"levenshtein",       lua_levenshtein},
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