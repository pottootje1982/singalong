module('singalongpdf', package.seeall)

require 'pdfdoc'
require 'libharuError'

local function getHeader(track)
  return string.format('%s - %s', track.customArtist or track.artist, track.customTitle or track.title)
end

local function writeOneSong(pdf, fileContent, track, site)
  if fileContent then
    local currPage
    local heading

    if site then
      heading = string.format('%s: %s', site, getHeader(track))
    else
      heading = string.format('%s', getHeader(track))
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

local function calcContentSpanInPages(pdf, tracks)
  local page = pdf.currPage
  local columnHeight = page.height - page.topMargin - page.bottomMargin
  local totalHeight = pdf.headerFont.size + #tracks * pdf.normalFont.size
  local nrColumns = totalHeight / columnHeight
  local nrPages = nrColumns / page.nrColumns
  return math.ceil(nrPages)
end

local function writeContent(pdf, tracks)
  pdf.currPage = pdf.pages[1] -- Assuming that pages already have been inserted before actual content
  pdf:showTextNextLine('Table of contents:', pdf.headerFont)

  -- Write headings
  pdf:showTextBlock(tracks, -- iterator
    function(i, track) -- formatFunc
      return getHeader(track)
    end,
    pdf.normalFont, -- font
    function(i, track) -- saveFunc
      track.contentPage = pdf.currPage
      track.column = pdf.currPage.currColumn
      track.x = pdf.currPage.x
      track.y = pdf.currPage.y
    end,
    true -- use already added pages for content
  )

  pdf.pageLabelWidth = pdf.currPage:textWidth('999')

  -- Draw dashed line behind every content item leading to page label
  for index, track in ipairs(tracks) do
    if track.contentPage then
      track.contentPage:setLineWidth(.1)
      track.contentPage:drawLine(track.contentPage:getColumnX(track.column+1) - pdf.pageLabelWidth, track.y, track.x, track.y, "dash")
    end
  end
end

local function writePageLabelsInContent(pdf, tracks)
  for index, track in ipairs(tracks) do
    local page = track.contentPage
    local posFunc = function()
      return page:getColumnX(track.column+1) - pdf.pageLabelWidth, track.y
    end
    page:showText(tostring(track.lyricsPage.pageNr), pdf.normalFont, posFunc)
  end
end

function generateSongbook(tracks, fileName)
  local mp3sCopy = {}
  -- Create a copy of tracks so that this table doesn't get polluted with entries
  -- like contentPage, lyricsPage, title, lyrics, column, x & y
  for i, track in ipairs(tracks) do
    table.insert(mp3sCopy, {artist = track.artist, title = track.title, customArtist = track.customArtist, customTitle = track.customTitle})
  end
  tracks = mp3sCopy

  local pdf = pdfdoc(config.twoside)

  pdf.headerFont = pdf:getFont("Times-Bold", 12)
  pdf.normalFont = pdf:getFont("Times-Roman", 9)

  local notFound = 0
  local existingMp3s = {}

  for index, track in ipairs(tracks) do
    lyrics = query.retrieveLyrics(track)
    if lyrics == query.GOOGLE_BAN then
      print('google ban')
      break
    end
    if lyrics then
      track.lyrics = lyrics
      table.insert(existingMp3s, track)
    else
      notFound = notFound + 1
    end
  end

  -- Add empty pages for table of contents before writing actual lyrics
  local nrPagesContent = calcContentSpanInPages(pdf, existingMp3s)
  pdf:addPage(nrPagesContent)

  -- Write lyrics
  for index, track in ipairs(existingMp3s) do
    track.lyricsPage = writeOneSong(pdf, track.lyrics, track)
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

  local selMp3, selMp3s = playlist_gui.getSelection()
  for _, track in pairs(selMp3s) do
    for _,search_site in pairs(customSearchSites or search_sites) do
      local _, fileContent = query.getLyrics('txt', search_site, track, false)
      writeOneSong(pdf, fileContent, track, search_site.site)
    end
  end

  pdf:save(fileName .. '.pdf')

  if config.preview then
    os.shellExecute(fileName .. '.pdf')
  end
end

return _M
