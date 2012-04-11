#include <lua.h>
#include "im.h"
#include "im_lib.h"
#include "im_image.h"
#include "im_convert.h"
#include "imlua.h"

int luaopen_imlua(lua_State *L)
{
  return imlua_open(L);
}

int luaopen_imlua51(lua_State *L)
{
  return imlua_open(L);
}
