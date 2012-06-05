require 'misc'

local header = [[\documentclass[a4paper,12pt]{%s} %% ********* two sided *********
\makeatletter
\usepackage[latin1]{inputenc}
\usepackage[titles]{tocloft}
\usepackage{color}
\usepackage{needspace}
\usepackage{titlesec}

\pagestyle{plain} %% No page headers

\titleclass{\chapter}{straight} %% No page break before chapter heading:
\titleformat{\chapter}[hang]
  {\normalfont\sffamily\Huge\bfseries} %% The Huge is this line applies to the chapter #
  {\thechapter}{10pt}{\Huge} %% Removed 'chapter #' before heading
\titlespacing{\chapter} %% Change chapter spacing
{0pt}{10pt}{5pt}

%% Set font size of chapter by changing font size of Huge
\renewcommand\Huge{
   \@setfontsize\Huge{%.1fpt}{%.1fpt}
   \abovedisplayskip 10\p@ \@plus2\p@ \@minus5\p@
   \abovedisplayshortskip \z@ \@plus3\p@
   \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
   \belowdisplayskip \abovedisplayskip
   \let\@listi\@listI}\normalsize

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
\fontsize{%d}{%d}\selectfont %% ********* Font size *********
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
  '20',
  '22',
  '24',
  '26',
  '28',
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
    config.twoside and 'book' or 'report',
    tonumber(config.fontSize) * 1.2, tonumber(config.fontSize) * 1.44,
    r, g, b,
    config.fontSize, tonumber(config.fontSize) * 1.2,
    useContent and content or '')
end

function getFooter()
  return footer
end
