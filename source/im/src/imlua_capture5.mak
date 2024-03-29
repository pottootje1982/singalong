PROJNAME = im
LIBNAME = imlua_capture
DEF_FILE = imlua_capture.def

OPT = YES

SRCDIR = lua5

SRC = imlua_capture.c

LIBS = im_capture

INCLUDES = lua5

ifdef USE_LUA52
  LIBNAME := $(LIBNAME)52
else
  USE_LUA51 = Yes
  LIBNAME := $(LIBNAME)51
endif

USE_IMLUA = Yes
NO_LUALINK = Yes
IM = ..
