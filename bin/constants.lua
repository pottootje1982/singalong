local header = [[\documentclass[a4paper,%spt]{%s} %% ********* two sided *********
\makeatletter
\usepackage[latin1]{inputenc}
\usepackage[titles]{tocloft}
\usepackage{color}
\usepackage{needspace}
\usepackage{titlesec}

\pagestyle{plain} %% No page headers

\titleclass{\chapter}{straight} %% No page break before chapter heading:
\titleformat{\chapter}[hang] %% Remove 'Chapter' label before chapter headings
{\normalfont\small\bfseries}{\thechapter}{10pt}{\small} %% Change chapter fonts/sizes
\titlespacing{\chapter} %% Change chapter spacing
{0pt}{10pt}{5pt}

\renewcommand{\cftchapnumwidth}{3em} %% A little more space for heading numbers in TOC
\setlength{\cftbeforechapskip}{0em} %% Position TOC entries closer to each other
\renewcommand{\cftchapdotsep}{3} %% Use dots after chapter entries in TOC

\definecolor{customColor}{rgb}{%f,%f,%f} %% ********* Font color *********
\usepackage[left=1cm,top=1cm,bottom=1.5cm,right=1.5cm,nohead,nofoot]{geometry}
\addtolength\oddsidemargin{10mm}
\addtolength\evensidemargin{-10mm}
\usepackage{multicol}
\begin{document}
\begin{multicols}{2}
\textcolor{customColor}{
%s %% ********* Content *********
]]
local content = [[\tableofcontents
\clearpage
]]

pdfGenerators = table.makeZeroBased
{
  'Miktex',
  'Singalong pdf',
}
fontSizes = table.makeZeroBased
{
  '8',
  '9',
  '10',
  '11',
  '12',
  '14',
  '16',
  '18',
  '10',
  '12',
  '14',
  '16',
  '18',
  '36',
  '48',
  '72'
}
whichSelection = table.makeZeroBased
{
  'All',
  'Selected',
  'Unfound',
}

local footer = [[
}
\end{multicols}
\end{document}]]

function getHeader(useContent)
  local r, g, b = getFontColor(config.fontColor)
  return string.format(header,
    config.fontSize,
    config.twoside and 'book' or 'report',
    r, g, b,
    useContent and content or '')
end

function getFooter()
  return footer
end
