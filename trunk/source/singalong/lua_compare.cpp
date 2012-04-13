#include "lua_compare.h"

#include <string.h>
#include <vector>
#include <algorithm>

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


static luaL_Reg compare_func[] = {
  {"levenshtein",       lua_levenshtein},
  {NULL,        NULL}
};

int luaopen_compare(lua_State *L)
{
  luaL_register(L, "compare", compare_func);
  return 0;
}