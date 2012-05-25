#pragma once

#ifdef WIN32
	#include <afxwin.h>
	#undef min
	#undef max
#else
#endif

#include <string>

extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}