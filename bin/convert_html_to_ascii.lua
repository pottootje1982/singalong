require 'misc'
require 'replace'

local html_tags_to_ascii =
{
  [[&quot;]], [["]],                  -- 34
  [[&amp;]]  ,[[&]],                 -- 38
  [[&lt;]]   ,[[<]],                -- 60
  [[&gt;]]   ,[[>]],                -- 62
  [[&nbsp;]],      [[�]],              -- 160
  [[&iexcl;]],     [[�]],              -- 161
  [[&cent;]],      [[�]],              -- 162
  [[&pound;]],     [[�]],              -- 163
  [[&curren;]],    [[�]],              -- 164
  [[&yen;]],       [[�]],              -- 165
  [[&brvbar;]],    [[�]],              -- 166
  [[&sect;]],      [[�]],              -- 167
  [[&uml;]],       [[�]],              -- 168
  [[&copy;]],      [[�]],              -- 169
  [[&ordf;]],      [[�]],              -- 170
  [[&laquo;]],     [[�]],              -- 171
  [[&not;]],       [[�]],              -- 172
  [[&shy;]],       [[�]],              -- 173
  [[&reg;]],       [[�]],              -- 174
  [[&macr;]],      [[�]],              -- 175
  [[&deg;]],       [[�]],              -- 176
  [[&plusmn;]],    [[�]],              -- 177
  [[&sup2;]],      [[�]],              -- 178
  [[&sup3;]],      [[�]],              -- 179
  [[&acute;]],     [[�]],              -- 180
  [[&micro;]],     [[�]],              -- 181
  [[&para;]],      [[�]],              -- 182
  [[&middot;]],    [[�]],              -- 183
  [[&cedil;]],     [[�]],              -- 184
  [[&sup1;]],      [[�]],              -- 185
  [[&ordm;]],      [[�]],              -- 186
  [[&raquo;]],     [[�]],              -- 187
  [[&frac14;]],    [[�]],              -- 188
  [[&frac12;]],    [[�]],              -- 189
  [[&frac34;]],    [[�]],              -- 190
  [[&iquest;]],    [[�]],              -- 191
  [[&Agrave;]],    [[�]],                -- 192
  [[&Aacute;]],    [[�]],                -- 193
  [[&Acirc;]],     [[�]],                -- 194
  [[&Atilde;]],    [[�]],                -- 195
  [[&Auml;]],      [[�]],                -- 196
  [[&Aring;]],     [[�]],                -- 197
  [[&Aelig;]],     [[�]],                -- 198
  [[&Ccedil;]],    [[�]],                -- 199
  [[&Egrave;]],    [[�]],                -- 200
  [[&Eacute;]],    [[�]],                -- 201
  [[&Ecirc;]],     [[�]],                -- 202
  [[&Euml;]],      [[�]],                -- 203
  [[&Igrave;]],    [[�]],                -- 204
  [[&Iacute;]],    [[�]],                -- 205
  [[&Icirc;]],     [[�]],                -- 206
  [[&Iuml;]],      [[�]],                -- 207
  [[&Eth;]],       [[�]],                -- 208
  [[&Ntilde;]],    [[�]],                -- 209
  [[&Ograve;]],    [[�]],                -- 210
  [[&Oacute;]],    [[�]],                -- 211
  [[&Ocirc;]],     [[�]],                -- 212
  [[&Otilde;]],    [[�]],                -- 213
  [[&Ouml;]],      [[�]],                -- 214
  [[&Times;]],     [[�]],                -- 215
  [[&Oslash;]],    [[�]],                -- 216
  [[&Ugrave;]],    [[�]],                -- 217
  [[&Uacute;]],    [[�]],                -- 218
  [[&Ucirc;]],     [[�]],                -- 219
  [[&Uuml;]],      [[�]],                -- 220
  [[&Yacute;]],    [[�]],                -- 221
  [[&thorn;]],     [[�]],                -- 222
  [[&szlig;]],     [[�]],                -- 223
  [[&agrave;]],    [[�]],                -- 224
  [[&aacute;]],    [[�]],                -- 225
  [[&acirc;]],     [[�]],                -- 226
  [[&atilde;]],    [[�]],                -- 227
  [[&auml;]],      [[�]],                -- 228
  [[&aring;]],     [[�]],                -- 229
  [[&aelig;]],     [[�]],                -- 230
  [[&ccedil;]],    [[�]],                -- 231
  [[&egrave;]],    [[�]],                -- 232
  [[&eacute;]],    [[�]],                -- 233
  [[&ecirc;]],     [[�]],                -- 234
  [[&euml;]],      [[�]],                -- 235
  [[&igrave;]],    [[�]],                -- 236
  [[&iacute;]],    [[�]],                -- 237
  [[&icirc;]],     [[�]],                -- 238
  [[&iuml;]],      [[�]],                -- 239
  [[&eth;]],       [[�]],                -- 240
  [[&ntilde;]],    [[�]],                -- 241
  [[&ograve;]],    [[�]],                -- 242
  [[&oacute;]],    [[�]],                -- 243
  [[&ocirc;]],     [[�]],                -- 244
  [[&otilde;]],    [[�]],                -- 245
  [[&ouml;]],      [[�]],                -- 246
  [[&divide;]],    [[�]],                -- 247
  [[&oslash;]],    [[�]],                -- 248
  [[&ugrave;]],    [[�]],                -- 249
  [[&uacute;]],    [[�]],                -- 250
  [[&ucirc;]],     [[�]],                -- 251
  [[&uuml;]],      [[�]],                -- 252
  [[&yacute;]],    [[�]],                -- 253
  [[&thorn;]],     [[�]],                -- 254
  [[&yuml;]],      [[�]],                -- 255
  [[&euro;]],      [[�]],                -- 8364
  [[&OElig;]],     [[�]],                -- 338
  [[&oelig;]],     [[�]],                -- 339
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
