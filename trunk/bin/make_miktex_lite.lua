require 'misc'
require 'lfs'

local MIKTEX_DIR = [[C:\temp\miktex\]]

local function uninstall(package)
  print('\n===========Removing package: '..package..'===============')
  local cwd = lfs.currentdir()
  lfs.chdir(MIKTEX_DIR .. [[miktex\bin\]])
  local command = string.format([[mpm --uninstall=%s]], package)
  os.execute(command)
  lfs.chdir(cwd)
end
local function install(package)
  print('\n===========Installing package: '..package..'===============')
  local cwd = lfs.currentdir()
  lfs.chdir(MIKTEX_DIR .. [[miktex\bin\]])
  local command = string.format([[mpm --install=%s]], package)
  os.execute(command)
  lfs.chdir(cwd)
end

--\Applications\Graphics
uninstall('pstricks')
uninstall('xypic')

--\Documentation
uninstall('latex2e-help-texinfo')
uninstall('tds')

--\Font\Font Support
uninstall('ae')

--\Fonts\METAFONT Fonts
uninstall('amsfont')

--\Fonts\Outline fonts
uninstall('avantgar')
uninstall('bookman')
uninstall('Courier')
uninstall('helvetic')
uninstall('hoekwater')
uninstall('palatino')
uninstall('utopia')
uninstall('lm')
uninstall('latex-fonts')
uninstall('ncntrsbk')
uninstall('zapfchan')
uninstall('zapfding')

--\FOrmats\Latex\Basic Latex
uninstall('amslatex')
uninstall('babel')
uninstall('graphics')
uninstall('ltxbase')
uninstall('psnfss')
uninstall('tools')

--\Format\Latex\Latex contrib
uninstall('hyperref')
--]]

--\
--[[
uninstall('dehyph-exptl')
uninstall('hyph-utf8')
--]]

--\Uncategorized
uninstall('bidi')
uninstall('enctex')
uninstall('euenc')
--uninstall('fontspec')
uninstall('ifxetex')
uninstall('miktex-dvips-doc')
uninstall('miktex-fontconfig-base')
uninstall('miktex-gsf2pk-base')
uninstall('miktex-hyph-usenglish')
uninstall('miktex-pdftex-doc-2.6')
uninstall('miktex-xetex-base')
uninstall('pdftex-def')
uninstall('thumbpdf')
uninstall('xetexref')
uninstall('xetexurl')
uninstall('xgreek')
uninstall('xkeyval')
uninstall('xltxtra')
uninstall('xunicode')

--[[
--\MiKTeX
install('miktex-bibtex8bit-base')
install('miktex-cweb-base')
install('miktex-doc-2.7')
install('miktex-dvipdfm-base-2.7')
install('miktex-dvipdfmx-base-2.7')
install('miktex-etex-base')
install('miktex-fontname-base')
install('miktex-freetype-base')
install('miktex-ghostscript-base')
install('miktex-makeindex-base')
install('miktex-metafont-base')
install('miktex-metapost-base-2.7')
--uninstall('miktex-mft-base')
install('miktex-misc')
install('miktex-nts-base')
--uninstall('miktex-omega-base')
--uninstall('miktex-pdftex-base')
install('miktex-psutils-base')
--uninstall('miktex-tex-base')
--uninstall('miktex-tex-misc')
install('miktex-texinfo-base')


--miktex\executables
uninstall('miktex-arctrl-bin-2.8')
uninstall('miktex-bibtex8bit-bin-2.8')
uninstall('miktex-cjkutils-bin-2.8')
uninstall('miktex-cweb-bin-2.8')
uninstall('miktex-dvicopy-bin-2.8')
uninstall('miktex-dvipdfm-bin-2.8')
uninstall('miktex-dvipdfmx-bin-2.8')
uninstall('miktex-dvipng-bin-2.8')
uninstall('miktex-dvips-bin-2.8')
uninstall('miktex-findtexmf-bin-2.8')
uninstall('miktex-fontconfig-bin-2.8')
uninstall('miktex-fonts-bin-2.8')
uninstall('miktex-freetype-bin-2.8')
uninstall('miktex-freetype2-bin-2.8')
uninstall('miktex-ghostscript-bin')
uninstall('miktex-graphics-bin-2.8')
uninstall('miktex-gsf2pk-bin-2.8')
uninstall('miktex-icu-bin')
uninstall('miktex-makeindex-bin-2.8')
uninstall('miktex-metafont-bin-2.8')
uninstall('miktex-metapost-bin-2.8')
uninstall('miktex-mfware-bin-2.8')
uninstall('miktex-mkfntmap-bin-2.8')
uninstall('miktex-mthelp-bin-2.8')
uninstall('miktex-mtprint-bin-2.8')
uninstall('miktex-omega-bin-2.8')
uninstall('miktex-ps2pk-bin-2.8')
uninstall('miktex-psutils-bin-2.8')
--uninstall('miktex-qt4-bin')
uninstall('miktex-teckit-bin-2.8')
uninstall('miktex-tex4ht-bin-2.8')
uninstall('miktex-texinfo-bin-2.8')
uninstall('miktex-vc90-bin-2.8')
uninstall('miktex-web-bin-2.8')
uninstall('miktex-xdvipdfmx-bin-2.8')
uninstall('miktex-xetex-bin-2.8')
uninstall('miktex-zip-bin-2.8')
--]]

os.removeDir(MIKTEX_DIR .. [[doc]])
