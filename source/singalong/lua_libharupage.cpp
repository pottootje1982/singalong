#include "hpdf.h"
#include "lua_libharupage.h"
#include <string.h>

const HPDF_UINT16 DASH_MODE1[] = {3};
const HPDF_UINT16 DASH_MODE2[] = {3, 7};
const HPDF_UINT16 DASH_MODE3[] = {8, 7, 2, 7};

int pdfpage_setOutlineDestination(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Outline outline = (HPDF_Outline)lua_touserdata(L, 2);
  HPDF_Destination dst = HPDF_Page_CreateDestination(*page);
  HPDF_Destination_SetXYZ(dst, 0, HPDF_Page_GetHeight(*page), 1);
  HPDF_Outline_SetDestination(outline, dst);
  return 0;
}

int pdfpage_setFontAndSize(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_SetFontAndSize(*page, (HPDF_Font)lua_touserdata(L, 2), lua_tonumber(L, 3));
  return 0;
}

int pdfpage_getTextLeading(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  lua_tonumber(L, HPDF_Page_GetTextLeading(*page));
  return 1;
}

int pdfpage_beginText(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_BeginText(*page);
  return 0;
}

int pdfpage_setTextLeading(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_SetTextLeading(*page, lua_tonumber(L, 2));
  return 0;
}

int pdfpage_showText(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  const char* text = lua_tostring(L, 2);
  HPDF_Page_ShowText(*page, text);
  return 0;
}

void getSubLine(char*& line, char* subLine, const int length)
{
  int lineLength = strlen(line);
  int i = length;
  if (lineLength > length)
  {
    while (i >= 0 && line[i] != ' ')
      i--;
  }
  else
  {
    strncpy(subLine, line, lineLength);
    subLine[lineLength] = '\0';
    line = NULL;
    return;
  }
  if (i <= 0)
    i = length;
  strncpy(subLine, line, i);
  subLine[i] = '\0';
  line += i + 1;
}

int pdfpage_showTextNextLine(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  char* line = (char*)lua_tostring(L, 2);
  if (line)
  {
    const int totalNrChars = strlen(line);
    HPDF_REAL textWidth = lua_tonumber(L, 3);
    HPDF_REAL realTextWidth;
    HPDF_UINT numChars = HPDF_Page_MeasureText(*page, line, textWidth, true, &realTextWidth);
    if (numChars < totalNrChars)
    {
      char *subLine = new char[numChars + 1];
      bool first = true;
      while (line)
      {
        getSubLine(line, subLine, numChars);
        if (!first)
        {
          HPDF_Page_ShowTextNextLine(*page, "  ");
          HPDF_Page_ShowText(*page, subLine);
        }
        else
          HPDF_Page_ShowTextNextLine(*page, subLine);
        first = false;
      } 
    }
    else
      HPDF_Page_ShowTextNextLine(*page, line);
  }
  HPDF_Point point = HPDF_Page_GetCurrentTextPos(*page);
  lua_pushnumber(L, point.x);
  lua_pushnumber(L, point.y);
  return 2;
}

int pdfpage_getCurrentTextPos(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Point point = HPDF_Page_GetCurrentTextPos(*page);
  lua_pushnumber(L, point.x);
  lua_pushnumber(L, point.y);
  return 2;
}

int pdfpage_setCurrentTextPos(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_MoveTextPos(*page, lua_tonumber(L, 2), lua_tonumber(L, 3));
  return 0;
}

int pdfpage_moveTextPos(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_MoveTextPos(*page, lua_tonumber(L, 2), lua_tonumber(L, 3));
  return 0;
}

int pdfpage_setLineWidth(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_SetLineWidth (*page, lua_tonumber(L, 2));
  return 0;
}

int pdfpage_moveTo(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_MoveTo(*page, lua_tonumber(L, 2), lua_tonumber(L, 3));
  return 0;
}

int pdfpage_drawLine(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  const char* style = lua_tostring(L, 6);
  if (!style) {}
  else if (strcmp(style, "dash") == 0)
    HPDF_Page_SetDash(*page, DASH_MODE1, 1, 1);
  HPDF_Page_MoveTo(*page, lua_tonumber(L, 2), lua_tonumber(L, 3));
  HPDF_Page_LineTo(*page, lua_tonumber(L, 4), lua_tonumber(L, 5));
  HPDF_Page_Stroke(*page);
  return 0;
}

int pdfpage_textWidth(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_REAL width = HPDF_Page_TextWidth(*page, lua_tostring(L,2));
  lua_pushnumber(L, width);
  return 1;
}

int pdfpage_endText(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_Page_EndText(*page);
  return 0;
}

int pdfpage_getDimension(lua_State *L)
{
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 1);
  HPDF_REAL width = HPDF_Page_GetWidth (*page);
  HPDF_REAL height = HPDF_Page_GetHeight (*page);
  lua_pushnumber(L, width);
  lua_pushnumber(L, height);
  return 2;
}
static luaL_Reg pdfpage_func[] = {
  {"setOutlineDestination", pdfpage_setOutlineDestination},
  {"setFontAndSize",      pdfpage_setFontAndSize},
  {"getTextLeading",      pdfpage_getTextLeading},
  {"beginText",           pdfpage_beginText},
  {"setTextLeading",      pdfpage_setTextLeading},
  {"showText",            pdfpage_showText},
  {"showTextNextLine",    pdfpage_showTextNextLine},
  {"getCurrentTextPos",   pdfpage_getCurrentTextPos},
  {"setCurrentTextPos",   pdfpage_setCurrentTextPos},
  {"moveTextPos",         pdfpage_moveTextPos},
  {"setLineWidth",        pdfpage_setLineWidth},
  {"moveTo",              pdfpage_moveTo},
  {"drawLine",            pdfpage_drawLine},
  {"textWidth",           pdfpage_textWidth},
  {"endText",             pdfpage_endText},
  {"getDimension",        pdfpage_getDimension},
  {NULL,        NULL}
};

void pdfpage_register(lua_State *L)
{
  luaL_register(L, "pdfpageC", pdfpage_func);

  luaL_newmetatable(L, "pdfpageC" );        /* create metatable for pdfpage,*/

  luaL_register(L, 0, pdfpage_func);  /* fill metatable */
  lua_pushliteral(L, "__index");
  lua_pushvalue(L, -3);               /* dup methods table*/
  lua_rawset(L, -3);                  /* metatable.__index = methods */

  lua_pop(L, 1);                      /* drop metatable */
}
