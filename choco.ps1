
####################
### choco ##########
####################
#
# [Windows使用choco包管理器_choco](https://blog.csdn.net/omaidb/article/details/120028664 )
$PSVersionTable

choco install tencentqq
choco install wechat


# choco config
choco feature enable -n=allowGlobalConfirmation
choco install choco-cleaner -y

# tools - cli
choco install wget curl gsudo grep fzf
choco install ripgrep
choco install lua

# tools - ui
choco install 7zip
choco install everything

choco install nodejs-lts
choco install foxitreader
choco install vscode

choco install wireshark


choco install postman
choco install autohotkey
choco install tor-browser
choco install imagemagick.app
choco install googlechrome
choco install calibre

# choco install pandoc
choco install texlive
choco install typora

choco install f.lux

choco install aida-extreme
choco install cpu-z

####################
### scoop ##########
####################
#
# [Scoop](https://scoop.sh/ )
scoop install SarasaGothic

####################
### winget #########
####################
winget install DEVCOM.Lua

winget install Tencent.qqmusic
winget install Tencent.qq
winget install Tencent.wechat
BurntSushi.ripgrep.MSVC
Lexikos.AutoHotkey
TorProject.TorBrowser

sharkdp.fd
flux.flux
Microsoft.VisualStudioCode
voidtools.Everything
winget install -e --id SomePythonThings.WingetUIStore

Foxit.FoxitReader
WiresharkFoundation.Wireshark

Google.Chrome.Dev
calibre.calibre     ? portable

junegunn.fzf
sharkdp.bat


