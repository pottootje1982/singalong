require 'misc'
require 'replace'

local html_tags_to_ascii =
{
  [[&quot;]], [["]],                  -- 34
  [[&amp;]]  ,[[&]],                 -- 38
  [[&lt;]]   ,[[<]],                -- 60
  [[&gt;]]   ,[[>]],                -- 62
  [[&nbsp;]],      [[ ]],              -- 160
  [[&iexcl;]],     [[¡]],              -- 161
  [[&cent;]],      [[¢]],              -- 162
  [[&pound;]],     [[£]],              -- 163
  [[&curren;]],    [[¤]],              -- 164
  [[&yen;]],       [[¥]],              -- 165
  [[&brvbar;]],    [[¦]],              -- 166
  [[&sect;]],      [[§]],              -- 167
  [[&uml;]],       [[¨]],              -- 168
  [[&copy;]],      [[©]],              -- 169
  [[&ordf;]],      [[ª]],              -- 170
  [[&laquo;]],     [[«]],              -- 171
  [[&not;]],       [[¬]],              -- 172
  [[&shy;]],       [[­]],              -- 173
  [[&reg;]],       [[®]],              -- 174
  [[&macr;]],      [[¯]],              -- 175
  [[&deg;]],       [[°]],              -- 176
  [[&plusmn;]],    [[±]],              -- 177
  [[&sup2;]],      [[²]],              -- 178
  [[&sup3;]],      [[³]],              -- 179
  [[&acute;]],     [[´]],              -- 180
  [[&micro;]],     [[µ]],              -- 181
  [[&para;]],      [[¶]],              -- 182
  [[&middot;]],    [[·]],              -- 183
  [[&cedil;]],     [[¸]],              -- 184
  [[&sup1;]],      [[¹]],              -- 185
  [[&ordm;]],      [[º]],              -- 186
  [[&raquo;]],     [[»]],              -- 187
  [[&frac14;]],    [[¼]],              -- 188
  [[&frac12;]],    [[½]],              -- 189
  [[&frac34;]],    [[¾]],              -- 190
  [[&iquest;]],    [[¿]],              -- 191
  [[&Agrave;]],    [[À]],                -- 192
  [[&Aacute;]],    [[Á]],                -- 193
  [[&Acirc;]],     [[Â]],                -- 194
  [[&Atilde;]],    [[Ã]],                -- 195
  [[&Auml;]],      [[Ä]],                -- 196
  [[&Aring;]],     [[Å]],                -- 197
  [[&Aelig;]],     [[Æ]],                -- 198
  [[&Ccedil;]],    [[Ç]],                -- 199
  [[&Egrave;]],    [[È]],                -- 200
  [[&Eacute;]],    [[É]],                -- 201
  [[&Ecirc;]],     [[Ê]],                -- 202
  [[&Euml;]],      [[Ë]],                -- 203
  [[&Igrave;]],    [[Ì]],                -- 204
  [[&Iacute;]],    [[Í]],                -- 205
  [[&Icirc;]],     [[Î]],                -- 206
  [[&Iuml;]],      [[Ï]],                -- 207
  [[&Eth;]],       [[Ð]],                -- 208
  [[&Ntilde;]],    [[Ñ]],                -- 209
  [[&Ograve;]],    [[Ò]],                -- 210
  [[&Oacute;]],    [[Ó]],                -- 211
  [[&Ocirc;]],     [[Ô]],                -- 212
  [[&Otilde;]],    [[Õ]],                -- 213
  [[&Ouml;]],      [[Ö]],                -- 214
  [[&Times;]],     [[×]],                -- 215
  [[&Oslash;]],    [[Ø]],                -- 216
  [[&Ugrave;]],    [[Ù]],                -- 217
  [[&Uacute;]],    [[Ú]],                -- 218
  [[&Ucirc;]],     [[Û]],                -- 219
  [[&Uuml;]],      [[Ü]],                -- 220
  [[&Yacute;]],    [[Ý]],                -- 221
  [[&thorn;]],     [[Þ]],                -- 222
  [[&szlig;]],     [[ß]],                -- 223
  [[&agrave;]],    [[à]],                -- 224
  [[&aacute;]],    [[á]],                -- 225
  [[&acirc;]],     [[â]],                -- 226
  [[&atilde;]],    [[ã]],                -- 227
  [[&auml;]],      [[ä]],                -- 228
  [[&aring;]],     [[å]],                -- 229
  [[&aelig;]],     [[æ]],                -- 230
  [[&ccedil;]],    [[ç]],                -- 231
  [[&egrave;]],    [[è]],                -- 232
  [[&eacute;]],    [[é]],                -- 233
  [[&ecirc;]],     [[ê]],                -- 234
  [[&euml;]],      [[ë]],                -- 235
  [[&igrave;]],    [[ì]],                -- 236
  [[&iacute;]],    [[í]],                -- 237
  [[&icirc;]],     [[î]],                -- 238
  [[&iuml;]],      [[ï]],                -- 239
  [[&eth;]],       [[ð]],                -- 240
  [[&ntilde;]],    [[ñ]],                -- 241
  [[&ograve;]],    [[ò]],                -- 242
  [[&oacute;]],    [[ó]],                -- 243
  [[&ocirc;]],     [[ô]],                -- 244
  [[&otilde;]],    [[õ]],                -- 245
  [[&ouml;]],      [[ö]],                -- 246
  [[&divide;]],    [[÷]],                -- 247
  [[&oslash;]],    [[ø]],                -- 248
  [[&ugrave;]],    [[ù]],                -- 249
  [[&uacute;]],    [[ú]],                -- 250
  [[&ucirc;]],     [[û]],                -- 251
  [[&uuml;]],      [[ü]],                -- 252
  [[&yacute;]],    [[ý]],                -- 253
  [[&thorn;]],     [[þ]],                -- 254
  [[&yuml;]],      [[ÿ]],                -- 255
  [[&euro;]],      [[€]],                -- 8364
  [[&OElig;]],     [[Œ]],                -- 338
  [[&oelig;]],     [[œ]],                -- 339
}

html_newlines_to_latex =
{
  '<br%s*/*>',     [[\\]],
}

local function convertHtmlSymbolsToAscii(str)
  for v in string.gmatch(str,"(&[%a]+;)") do
    index = table.ifind(html_tags_to_ascii, v)
    if index then
      str = str:gsub(v, html_tags_to_ascii[index+1])
    else
      print('WARNING: tag ', v, " couldn't be found!!!")
    end
  end
  return str
end

-- Specially designed for www.lyricsmode.com
local function convertHtmlCharsToAscii(str, endsWithSemicolon)
  local match = endsWithSemicolon and "(&#([%d]+);)" or "(&#([%d]+))"
  for v, dec in string.gmatch(str, match) do
    dec = tonumber(dec)
    if dec <= 255 then
      str = str:gsub(v, string.char(dec))
    else
      print('WARNING: tag ', v, " couldn't be found!!!")
    end
  end
  return str
end

local function convertHtmlNewlines(str)
  -- Remove HTML breaks
  str = replace(str, html_newlines_to_latex)

  -- Remove remaining html tags (opening tags matched with their endings
  for v, tagName in string.gmatch(str,[[(<(%w+)[^>]+>)]]) do
    local ending = string.format('.-</%s[^>]->', tagName)
    str = str:gsub(_(v) .. ending, '')
  end
  -- Remove remaining html tags
  for v, tagName in string.gmatch(str,[[(<(%w+)[^>]+>)]]) do
    str = str:gsub(_(v), '')
  end

  -- Remove html comments <!-- .... -->
  for v in string.gmatch(str,[[<!%-%-.-%-%->]]) do
    str = str:gsub(_(v), '')
  end

  return str
end

return
function(content)
  content = convertHtmlNewlines(content)
  content = convertHtmlSymbolsToAscii(content)
  content = convertHtmlCharsToAscii(content, true)
  content = convertHtmlCharsToAscii(content)
  return content
end
