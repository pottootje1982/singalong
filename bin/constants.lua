local header = [[\documentclass[a4paper,12pt%s]{book} %% ********* two sided *********
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
\%s %% ********* Font size *********
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
  'tiny',
  'scriptsize',
  'footnotesize',
  'small',
  'normalsize',
  'large',
  'Large',
  'LARGE',
  'huge',
  'Huge',
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
    config.twoside and ',twoside' or '',
    r, g, b,
    config.fontSize,
    useContent and content or '')
end

function getFooter()
  return footer
end
