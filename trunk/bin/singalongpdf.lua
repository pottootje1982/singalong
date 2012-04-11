module('singalongpdf', package.seeall)

require 'pdfdoc'
require 'libharuError'

local function getHeader(mp3)
  return string.format('%s - %s', mp3.customArtist or mp3.artist, mp3.customTitle or mp3.title)
end

local function writeOneSong(pdf, fileContent, mp3, site)
  if fileContent then
    local currPage
    local heading

    if site then
      heading = string.format('%s: %s', site, getHeader(mp3))
    else
      heading = string.format('%s', getHeader(mp3))
    end
    pdf:showTextNextLine(heading, pdf.headerFont)
    currPage = pdf.currPage

    pdf:showTextBlock(fileContent:gmatch('([^%c]*%c?)'), -- iterator
      function(line) -- formatFunc
        return line
      end,
      pdf.normalFont) -- font

    pdf:showTextNextLine('', pdf.normalFont)
    return currPage
  end
end

local function calcContentSpanInPages(pdf, mp3s)
  local page = pdf.currPage
  local columnHeight = page.height - page.topMargin - page.bottomMargin
  local totalHeight = pdf.headerFont.size + #mp3s * pdf.normalFont.size
  local nrColumns = totalHeight / columnHeight
  local nrPages = nrColumns / page.nrColumns
  return math.ceil(nrPages)
end

local function writeContent(pdf, mp3s)
  pdf.currPage = pdf.pages[1] -- Assuming that pages already have been inserted before actual content
  pdf:showTextNextLine('Table of contents:', pdf.headerFont)

  -- Write headings
  pdf:showTextBlock(mp3s, -- iterator
    function(i, mp3) -- formatFunc
      return getHeader(mp3)
    end,
    pdf.normalFont, -- font
    function(i, mp3) -- saveFunc
      mp3.contentPage = pdf.currPage
      mp3.column = pdf.currPage.currColumn
      mp3.x = pdf.currPage.x
      mp3.y = pdf.currPage.y
    end,
    true -- use already added pages for content
  )

  pdf.pageLabelWidth = pdf.currPage:textWidth('999')

  -- Draw dashed line behind every content item leading to page label
  for index, mp3 in ipairs(mp3s) do
    if mp3.contentPage then
      mp3.contentPage:setLineWidth(.1)
      mp3.contentPage:drawLine(mp3.contentPage:getColumnX(mp3.column+1) - pdf.pageLabelWidth, mp3.y, mp3.x, mp3.y, "dash")
    end
  end
end

local function writePageLabelsInContent(pdf, mp3s)
  for index, mp3 in ipairs(mp3s) do
    local page = mp3.contentPage
    local posFunc = function()
      return page:getColumnX(mp3.column+1) - pdf.pageLabelWidth, mp3.y
    end
    page:showText(tostring(mp3.lyricsPage.pageNr), pdf.normalFont, posFunc)
  end
end

function generateSongbook(mp3s, fileName)
  local mp3sCopy = {}
  -- Create a copy of mp3s so that this table doesn't get polluted with entries
  -- like contentPage, lyricsPage, title, lyrics, column, x & y
  for i, mp3 in ipairs(mp3s) do
    table.insert(mp3sCopy, {artist = mp3.artist, title = mp3.title, customArtist = mp3.customArtist, customTitle = mp3.customTitle})
  end
  mp3s = mp3sCopy

  local pdf = pdfdoc(config.twoside)

  pdf.headerFont = pdf:getFont("Times-Bold", 12)
  pdf.normalFont = pdf:getFont("Times-Roman", 9)

  local notFound = 0
  local existingMp3s = {}

  for index, mp3 in ipairs(mp3s) do
    lyrics = query.retrieveLyrics(mp3)
    if lyrics == query.GOOGLE_BAN then
      print('google ban')
      break
    end
    if lyrics then
      mp3.lyrics = lyrics
      table.insert(existingMp3s, mp3)
    else
      notFound = notFound + 1
    end
  end

  -- Add empty pages for table of contents before writing actual lyrics
  local nrPagesContent = calcContentSpanInPages(pdf, existingMp3s)
  pdf:addPage(nrPagesContent)

  -- Write lyrics
  for index, mp3 in ipairs(existingMp3s) do
    mp3.lyricsPage = writeOneSong(pdf, mp3.lyrics, mp3)
  end

  writeContent(pdf, existingMp3s)

  -- Show page labels at bottom of page
  pdf:showPageLabels(1, 1)
  -- Show page labels in table of contents
  writePageLabelsInContent(pdf, existingMp3s)

  pdf:save(fileName .. '.pdf')

  if config.preview then
    os.shellExecute(fileName .. '.pdf')
  end
end

function previewSites(fileName, customSearchSites)
  local pdf = pdfdoc(config.twoside)

  pdf.headerFont = pdf:getFont("Times-Bold", 12)
  pdf.normalFont = pdf:getFont("Times-Roman", 9)

  local selMp3, selMp3s = playlist_gui.widget:getSelection(mp3s)
  for _, mp3 in pairs(selMp3s) do
    for _,search_site in pairs(customSearchSites or search_sites) do
      local _, fileContent = query.getLyrics('txt', search_site, mp3, false)
      writeOneSong(pdf, fileContent, mp3, search_site.site)
    end
  end

  pdf:save(fileName .. '.pdf')

  if config.preview then
    os.shellExecute(fileName .. '.pdf')
  end
end

return _M
