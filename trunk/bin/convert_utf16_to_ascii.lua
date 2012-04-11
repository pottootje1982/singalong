require 'replace'

local utf16_to_ascii = 
{
  -- UTF16 conversions
  [[À]],                         [[�]],
  [[Á]],                          [[�]],
  [[Â]],                         [[�]],
  [[Ã]],                         [[�]],
  [[Ä]],                         [[�]],
  [[Å]],                         [[�]],
  [[Æ]],                         [[�]],
  [[Ç]],                         [[�]],
  [[È]],                         [[�]],
  [[É]],                         [[�]],
  [[Ê]],                         [[�]],
  [[Ë]],                         [[�]],
  [[Ì]],                         [[�]],
  [[Í]],                          [[�]],
  [[Î]],                         [[�]],
  [[Ï]],                          [[�]],
  [[Ð]],                          [[�]],
  [[Ñ]],                         [[�]],
  [[Ò]],                         [[�]],
  [[Ó]],                         [[�]],
  [[Ô]],                         [[�]],
  [[Õ]],                         [[�]],
  [[Ö]],                         [[�]],
  [[×]],                         [[�]],
  [[Ø]],                         [[�]],
  [[Ù]],                         [[�]],
  [[Ú]],                         [[�]],
  [[Û]],                         [[�]],
  [[Ü]],                         [[�]],
  [[Ý]],                          [[�]],
  [[Þ]],                         [[�]],
  [[ß]],                         [[�]],
  [[à]],                         [[�]],
  [[á]],                         [[�]],
  [[â]],                         [[�]],
  [[ã]],                         [[�]],
  [[ä]],                         [[�]],
  [[å]],                         [[�]],
  [[æ]],                         [[�]],
  [[ç]],                         [[�]],
  [[è]],                         [[�]],
  [[é]],                         [[�]],
  [[ê]],                         [[�]],
  [[ë]],                         [[�]],
  [[ì]],                         [[�]],
  [[í]],                         [[�]],
  [[î]],                         [[�]],
  [[ï]],                         [[�]],
  [[ð]],                         [[�]],
  [[ñ]],                         [[�]],
  [[ò]],                         [[�]],
  [[ó]],                         [[�]],
  [[ô]],                         [[�]],
  [[õ]],                         [[�]],
  [[ö]],                         [[�]],
  [[÷]],                         [[�]],
  [[ø]],                         [[�]],
  [[ù]],                         [[�]],
  [[ú]],                         [[�]],
  [[û]],                         [[�]],
  [[ü]],                         [[�]],
  [[ý]],                         [[�]],
  [[þ]],                         [[�]],
  [[ÿ]],                         [[�]],
  [[Œ]],                         [[�]],
  [[œ]],                         [[�]],
}

return 
function(str)
  return replace(str, utf16_to_ascii)
end