
#ifdef WIN32
	#include <afxwin.h>
	#undef min
	#undef max
#else
	typedef unsigned long DWORD;
	typedef unsigned short WORD;
	typedef unsigned int UNINT32;
	typedef unsigned int UINT;
#endif

extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}