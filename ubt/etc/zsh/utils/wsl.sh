# WSL config {{{
    # Fix xclip, so we can copy between win10 and linux.
    # Xclip depends on x11 on linux and Xserver on win10.
    # To make xclip works on vim, we also need install vim-gtk

    if uname -r | grep -qi "microsof" ; then
        fmt_info "We are in wsl~~~"

        # Export for WSL {{{
            # sys tools
            # export POWERSHELL_PATH="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powerShell.exe"
            export VSCODE_PATH="/mnt/c/Program Files/Microsoft VS Code/bin/code"
            export EXPLORER_PATH="/mnt/c/Windows/explorer.exe"
            export CMD_PATH="/mnt/c/Windows/system32/cmd.exe"
            export TYPORA_PATH="/mnt/c/Program Files/Typora/Typora.exe"
            export OBSIDIAN_PATH="/mnt/c/Users/owen/AppData/Local/Obsidian/Obsidian.exe"
            export DRAWIO_PATH="/mnt/d/owen/scoop/apps/draw.io/21.2.8/draw.io.exe"

            # network
            # export REMOTEHOST=${REMOTEHOST:-127.0.0.1}
            # export CLOUDHOST=${CLOUDHOST:-127.0.0.1}
            # export OPEN_PORTS_NUM=${OPEN_PORTS_NUM:-10}
            # export OPEN_PORTS_BASE=${OPEN_PORTS_BASE:-3050}
            # export PROXY_MODE=${PROXY_MODE:-"first"}
            # export TARGETHOST=${TARGETHOST:-"cloudhost"}
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
            export CONFIG_INSTALL_DIR_IN_WIN="/mnt/d"

            # Xserver connection check. It costs 1s.
            for i in $(seq 0 3); do
                # nc -zv winhost $((6000+$i)) -w1 2>& /dev/null
                timeout 0.2 nc -zv winhost $((6000+$i)) 2>& /dev/null
                [ $? != 0 ] && break
            done
            if [ $i -eq 0 ]; then
                fmt_warn "Xserver is unreachable"
                unalias vim 2>&/dev/null
                unset DISPLAY_XSERVER
            else
                fmt_info "Xserver is reachable at $DISPLAY_XSERVER"
                # xserver is running
                LAST_MONITOR=$((i-1))
                export DISPLAY_XSERVER=${WSL_GATEWAY}:${LAST_MONITOR}.0   # For mobaxterm x11 server.
                if [[ -n $WAYLAND_DISPLAY ]]; then
                    # Use xserver for clip in vim. Wayland is not for copy.
                    alias vim="DISPLAY=$DISPLAY_XSERVER vim "
                fi
            fi
        # }}}

        # Alias for WSL {{{
            alias \
            cmd="$CMD_PATH /C start "                             \
            wexp="$EXPLORER_PATH"                                 \
            wslp=wslpath                                          \
            winp="wslpath -w"                                     \
            hosts="vim /mnt/c/Windows/System32/drivers/etc/hosts" \
            pshc="vim $WinUserHome/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1" \
        # }}}

        # Network - init when WSL starting {{{
            local linux_wsl_started_flag=/tmp/.wsl_linux_started
            if [ ! -f $linux_wsl_started_flag ]; then 
                fmt_info "$WSL_DISTRO_NAME WSL is starting~~~"
                fmt_info "Configing"
                # etc/win10/init-wsl.ps1
                powershell.exe -File $PshDir'init-wsl.ps1' \
                    $WSL_DISTRO_NAME  $WSLIP  $WINIP  $PshDir
                # /tmp is tmpfs. Everytime linux system restart, /tmp will be flush
                touch $linux_wsl_started_flag    
            else
                fmt_info "$WSL_DISTRO_NAME WSL is already started~~~"
            fi

            local wsl_started_flag=/mnt/wsl/.wsl_started
            if [ ! -f $wsl_started_flag ]; then 
                fmt_info "Win10 WSL service is starting~~~"
                fmt_info "Configing none now"
                touch $wsl_started_flag    
            else
                fmt_info "Win10 WSL service is already started~~~"
            fi
        # }}}

        # Function for WSL {{{
            # system control{{{
                function shutdown() {
                    printf "shutdown $WSL_DISTRO_NAME ? [y/N]: " 
                    if read -q; then 
                        echo;  
                        powershell.exe wsl --terminate $WSL_DISTRO_NAME
                    fi
                }
            
                function IsWslPath() {
                    local filepath="$1"
                    echo "$filepath" | grep -q '/'
                    return $?
                }

                function check_and_return_winpath_array() {
                    g_winpaths=() # global var for return
                    local wslpaths=("$@")
                    local var winpath wslpath
                    for var in $(echo $wslpaths); do
                        if IsWslPath "$var"; then
                            # WSL path => Windows path
                            winpath=$(wslpath -wa "$var")
                            wslpath="$var"
                            if [[ $? != 0 ]] { return -1 }
                        else
                            winpath="$var"
                            wslpath=$(wslpath -ua "$var")
                            if [[ $? != 0 ]] { return -1 }
                        fi
                        if [ ! -e $wslpath  ]; then
                            fmt_error "$var" is no exist.
                            return -1
                        fi
                        g_winpaths+=("$winpath")
                        # echo "$winpath"
                    done
                    return 0
                }
                # call win exe with args convertion (wslpath => winpath)
                function call_win_exe() {
                    # check number of args.
                    # first arg is for limit args for win exe
                    local limit_num_of_args="${1}"
                    # get args [2,end] for win exe
                    local num_of_args="$(($# - 1))"
                    local args_for_exe=${@:2:$#}
                    if [[ $limit_num_of_args != -1 ]] &&   # -1 means no limit
                        [[ $num_of_args > $limit_num_of_args ]] {
                        print "too many args for win exe" \
                            "($num_of_args>$limit_num_of_args(limit))."
                        return -1
                    }
                    # iterate args from wslpaths => winpaths
                    # return g_winpaths array for winpaths
                    check_and_return_winpath_array $args_for_exe[@]
                    if [[ $? != 0 ]] {
                        print "args is illegal"
                        return -1
                    }
                    # execute win exe
                    "$g_win_cmdlist[@]" "$g_winpaths[@]"
                    return 0
                }
                function exp() {
                    1=${1:-.}  # default current directory
                    g_win_cmdlist=("$EXPLORER_PATH")
                    call_win_exe 1 "${@}"
                    [[ $? != 0 ]] && return -1
                }
                function rgf() {
                    rg --color=always --line-number --no-heading --smart-case "${*:-}" |
                      fzf --ansi \
                          --color "hl:-1:underline,hl+:-1:underline:reverse" \
                          --delimiter : \
                          --preview 'bat --color=always {1} --highlight-line {2}' \
                          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                          --bind 'enter:become(vim {1} +{2})'
                }
                function pshfile() {
                    check_and_return_winpath_array ${@}
                    if [[ $? != 0 ]] {
                        print "args is illegal"
                        return -1
                    }
                    powershell.exe -File "$g_winpaths[@]"
                }
                function ty() {
                    g_win_cmdlist=("$TYPORA_PATH")
                    call_win_exe 1 "${@}"
                    [[ $? != 0 ]] && return -1
                }
                function ob() {
                    g_win_cmdlist=("$OBSIDIAN_PATH")
                    call_win_exe 1 "${@}"
                    [[ $? != 0 ]] && return -1
                }
                function code() {
                    # vscode only receive wsl path
                    # g_win_cmdlist=("$VSCODE_PATH")
                    # call_win_exe -1 "${@}"
                    1=${1:-.}
                    $VSCODE_PATH "${@}"
                    [[ $? != 0 ]] && return -1
                }
                function da() {
                    g_win_cmdlist=("$DRAWIO_PATH")
                    call_win_exe 1 "${@}"
                    [[ $? != 0 ]] && return -1
                }
                function wpwd() {
                    local dir=${1:-"."}
                    wslpath -wa "$dir"
                }
                function wrp() {
                    local dir=${1:-"."}
                    wslpath -wa "$dir"
                }
            # }}}

            # droplist - manipulate win10 droplist (win10 clipboard) {{{
                function pshfile() {
                    local file=${PshDir}${1}
                    local action=${2}
                    local args_for_exe=${@:3:$#}
                    g_win_cmdlist=(powershell.exe -File $file $action)
                    call_win_exe -1 "$args_for_exe[@]"
                    [[ $? != 0 ]] && return -1
                }
                function yww() {
                    pshfile 'clipboard.ps1' "set" "${@}"
                    return $?
                }
                function ywa() {
                    pshfile 'clipboard.ps1' "push" "${@}"
                    return $?
                }
                function pww() {
                    local DesDirPath=$(wslpath -wa ${1:-.})
                    local imageName=${2:-"screenshot_"$(date +%Y%m%d-%H%M%S)".png"}
                    powershell.exe -File ${PshDir}'clipboard.ps1' "get" "$DesDirPath" "$imageName"
                }
                function pwm() {
                    DesDirPath=$(wslpath -wa ${1:-.})
                    pshfile 'mv-clip2file.ps1' "$DesDirPath"
                }
                alias pm=pwm
                function pwl() {
                    DesDirPath=$(wslpath -wa ${1:-.})
                    pshfile 'set-shortcut-from-clipboard.ps1' "$DesDirPath"
                }
                function musb {
                    sudo mkdir /mnt/$1
                    sudo mount -t drvfs $1: /mnt/$1
                }
                function wcd() {
                    [[ $# != 1 ]] && fmt_error "must have 1 arg" && return 1
                    local wslpath="$(wslpath "$*")"
                    fmt_info "cd to ${wslpath}"
                    cd "${wslpath}"
                }
            # }}}
        # }}}
    fi
# }}}
#

