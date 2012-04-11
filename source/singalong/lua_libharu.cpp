/*
 * << Haru Free PDF Library 2.0.0 >> -- font_demo.c
 *
 * Copyright (c) 1999-2006 Takeshi Kanno <takeshi_kanno@est.hi-ho.ne.jp>
 *
 * Permission to use, copy, modify, distribute and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.
 * It is provided "as is" without express or implied warranty.
 *
 */

#include "stdafx.h"
#include "lua_libharu.h"
#include <setjmp.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <new>
#include "hpdf.h"

const char *font_list[] = {
  "Courier",
  "Courier-Bold",
  "Courier-Oblique",
  "Courier-BoldOblique",
  "Helvetica",
  "Helvetica-Bold",
  "Helvetica-Oblique",
  "Helvetica-BoldOblique",
  "Times-Roman",
  "Times-Bold",
  "Times-Italic",
  "Times-BoldItalic",
  "Symbol",
  "ZapfDingbats",
  NULL
};

jmp_buf env;

void pcall(lua_State *L, int nArgs, int nResults, int errFunc)
{
  if (lua_pcall(L, nArgs, nResults, errFunc))
  {
    lua_error(L);
  }
}

#ifdef HPDF_DLL
void  __stdcall
#else
void
#endif
error_handler (HPDF_STATUS   error_no,
               HPDF_STATUS   detail_no,
               void         *user_data)
{
  lua_State *L = (lua_State *)user_data;
  lua_getfield(L, LUA_GLOBALSINDEX, "libharuError");
  if (!lua_isnil(L, -1))
  {
    lua_pushinteger(L, error_no);
    lua_pushinteger(L, detail_no);
    pcall(L, 2, 0, 0);
  }
  else
  {
    lua_pop(L, 1);
  }
}

int pdfdoc_new(lua_State *L)
{
  HPDF_Doc pdf = HPDF_New(error_handler, L);

  HPDF_Doc* pdfUD = (HPDF_Doc*)lua_newuserdata(L, sizeof(HPDF_Doc));
  *pdfUD = pdf;
  luaL_getmetatable(L, "pdfdocC");
  lua_setmetatable(L, -2);

  return 1;
}

int pdfdoc_createOutline(lua_State *L)
{
  HPDF_Doc* pdf = (HPDF_Doc*)lua_touserdata(L, 1);
  HPDF_Outline outline = HPDF_CreateOutline(*pdf, NULL, lua_tostring(L, 2), NULL);
  HPDF_Outline_SetOpened(outline, HPDF_TRUE);
  lua_pushlightuserdata(L, outline);
  return 1;
}

int pdfdoc_addPage(lua_State *L)
{
  HPDF_Doc* pdf = (HPDF_Doc*)lua_touserdata(L, 1);
  HPDF_Page page = HPDF_AddPage(*pdf);
  HPDF_Page_SetRGBFill  (page, lua_tonumber(L, 2), lua_tonumber(L, 3), lua_tonumber(L, 4));
  HPDF_Page* pageUD = (HPDF_Page*)lua_newuserdata(L, sizeof(HPDF_Page));
  *pageUD = page;
  luaL_getmetatable(L, "pdfpageC");
  lua_setmetatable(L, -2);
  return 1;
}

int pdfdoc_insertPage(lua_State *L)
{
  HPDF_Doc* pdf = (HPDF_Doc*)lua_touserdata(L, 1);
  HPDF_Page* page = (HPDF_Page*)lua_touserdata(L, 2);
  HPDF_Page newPage = HPDF_InsertPage(*pdf, *page);
  HPDF_Page* pageUD = (HPDF_Page*)lua_newuserdata(L, sizeof(HPDF_Page));
  *pageUD = newPage;
  luaL_getmetatable(L, "pdfpageC");
  lua_setmetatable(L, -2);
  return 1;
}

int pdfdoc_getFont(lua_State *L)
{
  HPDF_Doc* pdf = (HPDF_Doc*)lua_touserdata(L, 1);
  lua_pushlightuserdata(L, HPDF_GetFont(*pdf, lua_tostring(L, 2), lua_tostring(L, 3)));
  return 1;
}

int pdfdoc_addPageLabel(lua_State *L)
{
  HPDF_Doc* pdf = (HPDF_Doc*)lua_touserdata(L, 1);
  HPDF_STATUS stat = HPDF_AddPageLabel(*pdf, lua_tointeger(L, 2), HPDF_PAGE_NUM_STYLE_DECIMAL, lua_tointeger(L, 3), lua_tostring(L, 4));
  return 0;
}

int pdfdoc_setPageMode(lua_State *L)
{
  HPDF_Doc* pdf = (HPDF_Doc*)lua_touserdata(L, 1);
  HPDF_SetPageMode(*pdf, (HPDF_PageMode)lua_tointeger(L, 2));
  return 0;
}

int pdfdoc_save(lua_State *L)
{
  HPDF_Doc* pdf = (HPDF_Doc*)lua_touserdata(L, 1);
  HPDF_SaveToFile (*pdf, lua_tostring(L, 2));
  HPDF_Free (*pdf);
  return 0;
}

int lua_pdfDemo( lua_State *L )
{
  //const char *page_title = "Font Demo";
  //HPDF_Doc  pdf;
  //char fname[256];
  //HPDF_Page page;
  //HPDF_Font def_font;
  //HPDF_REAL tw;
  //HPDF_REAL height;
  //HPDF_REAL width;
  //HPDF_UINT i;

  //strcpy (fname, lua_tostring(L, 1));
  //strcat (fname, ".pdf");

  //pdf = HPDF_New (error_handler, NULL);
  //if (!pdf) {
  //  printf ("error: cannot create PdfDoc object\n");
  //  return 1;
  //}

  //if (setjmp(env)) {
  //  HPDF_Free (pdf);
  //  return 1;
  //}

  ///* Add a new page object. */
  //page = HPDF_AddPage (pdf);

  //height = HPDF_Page_GetHeight (page);
  //width = HPDF_Page_GetWidth (page);

  ///* Print the lines of the page. */
  //HPDF_Page_SetLineWidth (page, 1);
  //HPDF_Page_Rectangle (page, 50, 50, width - 100, height - 110);
  //HPDF_Page_Stroke (page);

  ///* Print the title of the page (with positioning center). */
  //def_font = HPDF_GetFont (pdf, "Helvetica", NULL);
  //HPDF_Page_SetFontAndSize (page, def_font, 24);

  //tw = HPDF_Page_TextWidth (page, page_title);
  //HPDF_Page_BeginText (page);
  //HPDF_Page_TextOut (page, (width - tw) / 2, height - 50, page_title);
  //HPDF_Page_EndText (page);

  ///* output subtitle. */
  //HPDF_Page_BeginText (page);
  //HPDF_Page_SetFontAndSize (page, def_font, 16);
  //HPDF_Page_TextOut (page, 60, height - 80, "<Standerd Type1 fonts samples>");
  //HPDF_Page_EndText (page);

  //HPDF_Page_BeginText (page);
  //HPDF_Page_MoveTextPos (page, 60, height - 105);

  //i = 0;
  //while (font_list[i]) {
  //  const char* samp_text = "abcdefgABCDEFG12345!#$%&+-@?";
  //  HPDF_Font font = HPDF_GetFont (pdf, font_list[i], NULL);

  //  /* print a label of text */
  //  HPDF_Page_SetFontAndSize (page, def_font, 9);
  //  HPDF_Page_ShowText (page, font_list[i]);
  //  HPDF_Page_MoveTextPos (page, 0, -18);

  //  /* print a sample text. */
  //  HPDF_Page_SetFontAndSize (page, font, 20);
  //  HPDF_Page_ShowText (page, samp_text);
  //  HPDF_Page_MoveTextPos (page, 0, -20);

  //  i++;
  //}

  //HPDF_Page_EndText (page);

  //HPDF_SaveToFile (pdf, fname);

  ///* clean up */
  //HPDF_Free (pdf);

  return 0;
}

static luaL_Reg pdfdoc_func[] = {
  {"pdfDemo",             lua_pdfDemo},
  {"new",                 pdfdoc_new},
  {"createOutline",       pdfdoc_createOutline},
  {"addPage",             pdfdoc_addPage},
  {"insertPage",          pdfdoc_insertPage},
  {"getFont",             pdfdoc_getFont},
  {"addPageLabel",        pdfdoc_addPageLabel},
  {"setPageMode",         pdfdoc_setPageMode},
  {"save",                pdfdoc_save},
  {NULL,        NULL}
};

void pdfdoc_register(lua_State *L)
{
  luaL_register(L, "pdfdocC", pdfdoc_func);

  luaL_newmetatable(L, "pdfdocC" );        /* create metatable for pdfdoc,*/

  luaL_register(L, 0, pdfdoc_func);  /* fill metatable */
  lua_pushliteral(L, "__index");
  lua_pushvalue(L, -3);               /* dup methods table*/
  lua_rawset(L, -3);                  /* metatable.__index = methods */

  lua_pop(L, 1);                      /* drop metatable */
}

