
#ifdef WIN32
	#include <afxwin.h>
	#undef min
	#undef max
#else
#endif

extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}