require 'class'

class 'pdfdoc'
class 'pdfpage'
class 'pdffont'

--------------------------------------------- pdfdoc ---------------------------------------------

local LEFTMARGIN, RIGHTMARGIN = 50, 20
local TOPMARGIN, BOTTOMMARGIN = 20, 50
local COLUMNSPACING = 10

HPDF_PAGE_MODE_USE_NONE=0
HPDF_PAGE_MODE_USE_OUTLINE=1
HPDF_PAGE_MODE_USE_THUMBS=2
HPDF_PAGE_MODE_FULL_SCREEN=3

-- alternateHorMargins: whether to alternate left and right margins every odd/even page (handy when binding papers in map)
-- leftMargin: the left margin of a page
-- rightMargin: the right margin of a page
-- topMargin: the top margin of a page
-- bottomMargin: the bottom margin of a page
function pdfdoc:pdfdoc(alternateHorMargins, leftMargin, rightMargin, topMargin, bottomMargin)
  self.c = pdfdocC.new()
  self.pages = {}

  self.alternateHorMargins = alternateHorMargins
  self.leftMargin = leftMargin or LEFTMARGIN
  self.rightMargin = rightMargin or RIGHTMARGIN
  self.topMargin = topMargin or TOPMARGIN
  self.bottomMargin = bottomMargin or BOTTOMMARGIN

  self.encoding = "WinAnsiEncoding"

  self.pageNrFont = self:getFont("Times-Roman", 10)
  self:addPage()
end

function pdfdoc:getMargins(pageNr)
  local leftMargin, rightMargin = self.leftMargin, self.rightMargin
  if self.alternateHorMargins and pageNr % 2 == 0 then -- swap margin for even pages
    leftMargin, rightMargin = rightMargin, leftMargin
  end
  local topMargin, bottomMargin = self.topMargin, self.bottomMargin
  return leftMargin, rightMargin, topMargin, bottomMargin
end

function pdfdoc:addPage(nrPagesToAdd)
  local nrPages = #self.pages
  local leftMargin, rightMargin, topMargin, bottomMargin = self:getMargins(nrPages + 1)
  for i = 1, (nrPagesToAdd or 1) do
    -- Numbers in addPage is text color RGB
    self.currPage = pdfpage(self.c:addPage(getFontColor(config.fontColor)), leftMargin, rightMargin, topMargin, bottomMargin)
    table.insert(self.pages, self.currPage)
  end
  return self.currPage
end

function pdfdoc:showPageLabels(beginPage, beginNumber)
  for i = beginPage, #self.pages do
    self.pages[i]:showPageLabel(self.pageNrFont, i + beginNumber - 1)
  end
end

function pdfdoc:showTextNextLine(text, font, doNotAddNewPages)
  local newPage, newColumn = self.currPage:checkNewColumnOrPage(font)
  if newPage or newColumn then
    self.currPage:endText()
  end
  if newPage then
    if doNotAddNewPages then
      local pageIndex = table.ifind(self.pages, self.currPage)
      self.currPage = self.pages[pageIndex + 1]
    else
      self:addPage()
    end
  end
  self.currPage:showTextNextLine(text, font)
end

-- doNotAddNewPages = true if you want to skip to next page if page if full (assuming that empty pages already have been added)
function pdfdoc:showTextBlock(iterator, formatFunc, font, saveFunc, doNotAddNewPages)
  self.currPage:initPage(font)
  local function iteratorFunc(...)
    local line = formatFunc(...)
    self:showTextNextLine(line, font, doNotAddNewPages)
    if saveFunc then saveFunc(...) end
  end
  if type(iterator) == 'function' then
    for a, b, c in iterator do
      iteratorFunc(a, b, c)
    end
  elseif type(iterator) == 'table' then
    for i, v in ipairs(iterator) do
      iteratorFunc(i, v)
    end
  end
  self.currPage:deinitPage()
end

function pdfdoc:getFont(name, size)
  local font = pdffont(self.c:getFont(name, self.encoding), size)
  return font
end

--------------------------------------------- pdfpage ---------------------------------------------

function pdfpage:pdfpage(c, leftMargin, rightMargin, topMargin, bottomMargin)
  self.c = c
  self.width, self.height = self:getDimension()
  self.currColumn = 1
  self.nrColumns = 2
  self.leftMargin = leftMargin
  self.rightMargin = rightMargin
  self.topMargin = topMargin
  self.bottomMargin = bottomMargin
  self.columnWidth = (self.width - self.leftMargin - self.rightMargin) / self.nrColumns
  self.x, self.y = self:getColumnX(), self.height - self.topMargin
end

function pdfpage:getColumnX(currColumn)
  return ((self.width - self.leftMargin - self.rightMargin) / self.nrColumns) * ((currColumn or self.currColumn) - 1) + self.leftMargin
end

function pdfpage:beginText()
  if self.status ~= 'beginText' then
    self.status = 'beginText'
    self.c:beginText()
    return true
  end
end

function pdfpage:endText()
  if self.status == 'beginText' then
    self.status = 'endText'
    self.c:endText()
  end
end

function pdfpage:initPage(font, posFunc)
  if self:beginText() then
    self.currFont = font or self.currFont
    self:setTextLeading(self.currFont.size)
    self:setFontAndSize(self.currFont.c, self.currFont.size)
    local x, y = self:getColumnX(), self.y
    if posFunc then x, y = posFunc() end
    self:moveTextPos(x, y)
  end
end

function pdfpage:deinitPage()
  self:endText()
end

function pdfpage:checkNewColumnOrPage(font)
  font = font or self.currFont
  local newColumn = false
  local newPage = false
  if self.y - font.size < self.bottomMargin then
    newColumn = true
    if self.currColumn == self.nrColumns then
      newPage = true
    end
    self.currColumn = self.currColumn % self.nrColumns + 1
    self.y = self.height - self.topMargin
  end
  return newPage, newColumn
end

function pdfpage:showTextNextLine(text, font, moreText)
  self:initPage(font)
  self.x, self.y = self.c:showTextNextLine(text, self.columnWidth - COLUMNSPACING)
  if not moreText then
    self:endText()
  end
end

function pdfpage:showText(text, font, posFunc)
  self:initPage(font, posFunc)
  self.c:showText(text)
  self:deinitPage()
end

function pdfpage:showPageLabel(pageNrFont, pageNr)
  self.pageNr = pageNr
  local label = '-'..pageNr..'-'
  local posFunc = function()
    local w = self:textWidth(label)
    return self.width / 2 - w / 2, self.bottomMargin / 2
  end
  self:showText(label, pageNrFont, posFunc)
end

--------------------------------------------- pdffont ---------------------------------------------

function pdffont:pdffont(font, size)
  self.c = font
  self.size = size
end
