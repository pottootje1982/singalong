#pragma once

#include "hpdf.h"

class PdfDoc
{
private:

  static const int X_MARGIN = 10;
  static const int Y_MARGIN = 10;

  int m_NrColumns;
  int m_CurrentColumn;


public:

  HPDF_Doc pdfDoc;
  HPDF_REAL m_X;
  HPDF_REAL m_Y;
  HPDF_REAL m_Width;
  HPDF_REAL m_Height;

  PdfDoc();
  HPDF_Page GetCurrentPage();
  HPDF_Font GetFont(const char *font);
  void Print(const char *text, HPDF_Font font, int size, bool rightAlign);
  void InsertNewPage(int at);
  void Save(const char* file);
};