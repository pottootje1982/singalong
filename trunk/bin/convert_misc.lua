require 'replace'

local misc_replacements = {
  '(\\\\%c\\\\)[%s%c\\]+',      '%1', -- replace more than 2 latex newlines
  '([%d]+:[%d]+)',              '',   -- timing tags
  '(\n)[ \t]+([^%s]+)',         '%1%2', -- remove trailing spaces
  --'(%c)[%c]+',                  '%1',
  '%[([^]]+)%]',                '{%1}',

  -- HTML tags
  '<[^>^%c]+>',                 '',
  '’',                        "'",

  -- Useless symbols (to be removed)
  '%$',                         '',
  '#',                          '',
  '%-[-]+',                     '',
  '=[=]+',                      '',
}

local misc_replacements_once =
{
  '^[%s%c\\]+([^%s^%c^\\])',    [[%1]], -- replace newlines in the beginning
  '([^%s^%c^\\])[%s%c\\]+$',    [[%1]], -- replaces any newlines at the end
}

return
function(str)
  str = replace(str, misc_replacements)
  str = replace(str, misc_replacements_once, 1)
  return str
end
