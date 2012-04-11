#include "stdafx.h"

#include "PdfDoc.h"
#include <setjmp.h>

jmp_buf env;

#ifdef HPDF_DLL
void  __stdcall
#else
void
#endif
error_handler (HPDF_STATUS   error_no,
               HPDF_STATUS   detail_no,
               void         *user_data)
{
  printf ("ERROR: error_no=%04X, detail_no=%u\n", (HPDF_UINT)error_no,
    (HPDF_UINT)detail_no);
  longjmp(env, 1);
}

PdfDoc::PdfDoc()
{
  pdfDoc = HPDF_New(error_handler, NULL);
  HPDF_Page page = HPDF_AddPage (pdfDoc);
  m_Width = HPDF_Page_GetWidth (page);
  m_Height = HPDF_Page_GetHeight (page);
  m_X = X_MARGIN;
  m_Y = m_Height - Y_MARGIN;

  m_NrColumns = 2;
  m_CurrentColumn = 0;
}

HPDF_Page PdfDoc::GetCurrentPage()
{
  HPDF_Page page = HPDF_GetCurrentPage(pdfDoc);

  if (!page)
  {
    page = HPDF_AddPage (pdfDoc);
  }
  return page;
}

HPDF_Font PdfDoc::GetFont( const char *font )
{
  return HPDF_GetFont (pdfDoc, font, NULL);
}

void PdfDoc::Print( const char *text, HPDF_Font font, int size, bool rightAlign )
{
  HPDF_Page page = GetCurrentPage();
  //m_Y -= size;
  //if (m_Y < Y_MARGIN)
  //{
  //  m_Y = m_Height - Y_MARGIN;
  //  m_CurrentColumn = (m_CurrentColumn + 1) % m_NrColumns;
  //  if (m_CurrentColumn == 0)
  //  {
  //    page = HPDF_AddPage (pdfDoc);
  //  }
  //  m_X = ((m_Width - 2*X_MARGIN) / m_NrColumns) * m_CurrentColumn + X_MARGIN;
  //}
  HPDF_Page_SetFontAndSize (page, font, size);

  HPDF_Box bbox = HPDF_Font_GetBBox(HPDF_Page_GetCurrentFont(page));
  HPDF_REAL height = HPDF_Font_GetDescent(HPDF_Page_GetCurrentFont(page));

  // Gets number of chars that fit in specified width
  //HPDF_Page_MeasureText  (page,
  //  text,
  //  HPDF_REAL    width,
  //  HPDF_BOOL    wordwrap,
  //  HPDF_REAL   *real_width);

  HPDF_Page_BeginText (page);

  HPDF_Point point = HPDF_Page_GetCurrentTextPos(page);
  if (point.y < Y_MARGIN)
    HPDF_Page_MoveTextPos(page, m_X, m_Y);

  HPDF_Page_ShowTextNextLine (page, text);
  HPDF_Page_EndText (page);
}

void PdfDoc::InsertNewPage(int at)
{
  //HPDF_InsertPage()
}

void PdfDoc::Save(const char* file)
{
  HPDF_SaveToFile (pdfDoc, file);
  HPDF_Free (pdfDoc);
}