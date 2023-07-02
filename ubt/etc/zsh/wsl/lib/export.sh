# export POWERSHELL_PATH="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powerShell.exe"
export VSCODE_PATH="/mnt/c/Program Files/Microsoft VS Code/bin/code"
export EXPLORER_PATH="/mnt/c/Windows/explorer.exe"
export CMD_PATH="/mnt/c/Windows/system32/cmd.exe"
export TYPORA_PATH="/mnt/c/Program Files/Typora/Typora.exe"
export OBSIDIAN_PATH="/mnt/c/Users/owen/AppData/Local/Obsidian/Obsidian.exe"
export DRAWIO_PATH="/mnt/d/owen/scoop/apps/draw.io/21.2.8/draw.io.exe"

# network
export PROXY_PORT=${PROXY_PORT:-10809}
# export all_proxy="http://$WINIP:$PROXY_PORT"
export WSL_GATEWAY=$(ip route | grep -w default | awk '{print $3}')
export WINIP=${WSL_GATEWAY}
export WSLIP=$(ip addr show dev eth0 | sed -n 's#.*inet \([^/]*\).*#\1#p')
# export WINIP=${WINIP:-192.168.50.10}
export all_proxy=${all_proxy:-http://$WSL_GATEWAY:10809}
# export all_proxy="socks5://$WINIP:10808" # v2ray
# export DISPLAY="$WINIP:0.0"              # For X11 server, so we can xclip.
export DISPLAY=":0.0"   # For xwayland server. It is unix socket.
export CONFIG_INSTALL_DIR_IN_WSL=
# export OwenInstallDirInWin=$(wslpath -ua "$(cmd.exe /c echo %OwenInstallDir% | tr -d '\r')")
export PshDir='D:\.dotfiles\scripts\psh\'
