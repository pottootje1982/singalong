require 'luaunit'

TestConversion = {}

function TestConversion:testConvertHtmlToAscii()
  local text = [[I am a poor wayfarin' stranger<br />

Travellin' through this world alone<br />

    There is no sickness, toil nor danger<br />

In that fair land to which I go<br />

<br />

I'm goin' home to see my mother<br />

]]
  local converted = require 'convert_html_to_ascii'(text)
  converted = require 'convert_misc'(converted)
  converted = require 'convert_utf16_to_ascii'(converted)
    assertEquals(converted, [[I am a poor wayfarin' stranger
Travellin' through this world alone
There is no sickness, toil nor danger
In that fair land to which I go

I'm goin' home to see my mother]])
end

function TestConversion:testWhiteSpace()
  local test = [[

  ]]
  assert(test:match('^%s*$'))
end

