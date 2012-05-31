module('miktex', package.seeall)

function getMiktexDir(miktexDir)
  return (miktexDir or config.miktexDir) .. [[\miktex\bin]]
end

local function texify(filename, postfix)
  local filePath = os.getPath(filename) or '.'
  local includeDir = lfs.currentdir() .. [[\latex]]
  local command = string.format([[%s\%s]], getMiktexDir(), 'texify.exe')
  local args = string.format(' -e -q -I "%s" -I "%s" "%s" %s', includeDir, filePath, filename, postfix or '')
  os.shellExecute(args, command, nil, filePath)
  print('Command executed:', command, args)
  return res
end

local function viewTexFile(fileName, preview)
  local outputName = fileName .. '.pdf'
  local outputFile = io.open(outputName, 'w')
  if not outputFile then
    iup.Message('Error', string.format('Unable to write to file %q', outputName))
    return
  else
    outputFile:close()
  end
  os.remove(fileName .. '.log')
  os.remove(fileName .. '.aux')
  os.remove(fileName .. '.pdf')
  os.remove(fileName .. '.dvi')

  if preview == nil then preview = true end
  texify(fileName .. '.tex', '-p')
  if preview then
    os.shellExecute(outputName)
  end
  if lfs.attributes(outputName) then
    return outputName
  end
end

local function getHeading(track)
  local heading = (track.customArtist or track.artist) .. ' - ' .. (track.customTitle or track.title)
  heading = require('convert_ascii_to_latex')(heading)
  return heading
end

function previewSites(fileName, customSearchSites)
  if not os.checkIfFileExists(getMiktexDir(), 'texify.exe') then
    return
  end

  local texFile = fileName .. '.tex'
  texFile = texFile
  os.remove(texFile)
  local content = getHeader()
  local selMp3, selMp3s = playlist_gui.getSelection()
  for _, track in pairs(selMp3s) do
    for _,search_site in pairs(customSearchSites or search_sites) do
      local _, fileContent = query.getLyrics('txt', search_site, track, false)
      if fileContent then
        local heading = string.format('\\chapter{%s: %s}\n\\noindent\n', search_site.site, getHeading(track))
        content = content .. heading .. fileContent
      end
    end
  end
  content = content .. getFooter()
  os.writeTo(texFile, content)

  viewTexFile(fileName, config.preview)
end

function generateSongbook(tracks, fileName)
  if not os.checkIfFileExists(getMiktexDir(), 'texify.exe') then
    return
  end

  local content = getHeader(true)
  local notFound = 0

  for index, track in ipairs(tracks) do
    lyrics = query.retrieveLyrics(track)

    if lyrics == query.GOOGLE_BAN then
      print('google ban')
      break
    end
    if lyrics then
      local needspace = config.avoidPageBreaks and string.format([[\Needspace*{%d\baselineskip}{]], string.count(lyrics, [[\\]])) or ''
      local heading = needspace .. '\\chapter{' .. getHeading(track) .. '}\n\\noindent\n'
      content = content .. heading
      local needSpaceEnding = config.avoidPageBreaks and '}' or ''
      content = content .. lyrics .. needSpaceEnding .. '\n'
    else
      notFound = notFound + 1
    end
  end

  print('#Lyrics not found: ' .. notFound)

  content = content .. getFooter()

  os.writeTo(fileName .. '.tex', content)

  viewTexFile(fileName, config.preview)
end

return _M
