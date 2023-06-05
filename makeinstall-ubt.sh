#!/usr/bin/zsh
#
export WinUserName=$(echo $PATH | sed 's#.*/mnt/c/Users/\([^/]*\)/.*#\1#')
export WinUserHome=/mnt/c/Users/${WinUserName}
export WinUserDownloads=${WinUserHome}/Downloads
export WinUserDesktop=${WinUserHome}/Desktop
export WinUserWeiyun="/mnt/c/Weiyun/Personal"
export WinUserWeiyunNote="/mnt/c/Weiyun/Personal/my_note"

function try_config() {
    local file=$1
    local msg=$2
    MarkLine="# owen configed" 
    if ! grep -q "$MarkLine" $file ; then
        fmt_info "owen $file is configing"
        echo "$MarkLine"                      >> $file
        echo "# -- owen $file config -- "     >> $file
        echo "$msg"                           >> $file
        echo "# -- end owen $file config -- " >> $file
    else
        fmt_info "owen $file is configed already"
    fi
}

# log function {{{
FMT_RED=$(printf '\033[31m')
FMT_GREEN=$(printf '\033[32m')
FMT_YELLOW=$(printf '\033[33m')
FMT_BLUE=$(printf '\033[34m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

function fmt_info() {
    printf '%sINFO: %s%s\n' "${FMT_GREEN}${FMT_BOLD}" "$*" "$FMT_RESET"
}

function fmt_error() {
    printf '%sERRO: [%s] %s%s\n' "${FMT_RED}${FMT_BOLD}" "$funcstack[2] $@" "$*" "$FMT_RESET"  1>&2
}
# }}}

function main() {
    ## override config
    mkdir -p ~/.local $$ mkdir -p ~/.config
    rsync -r etc          ~/.local/
    rsync -r etc/ranger   ~/.config/
    rsync -r etc/newsboat ~/.config/
    rsync -r etc/fzf      ~/.config/
    ln -sf ~/.local/etc/vim/vimrc ~/.vimrc
    ln -sf ~/.local/etc/vim/vimrc ~/.vimrc

    ### Force echo to zsh tmux config file
    if [[ $1 = "f" ]]; then
        _owen_force_update=1
        fmt_info "Force update config files including zsh,tmux"
        fmt_info "You must take care of the duplicated term in zsh/tmux config file~~~"
        fmt_info "zsh  $(realpath ~/.zshrc)"
        fmt_info "tmux $(realpath ~/.tmux.conf)"
    else
        _owen_force_update=
    fi

    # WSL config. cp pac to win10. ubt do not need it, because we use proxychain to manual control.
    if uname -r | grep -qi "microsof"; then
        fmt_info "We are in wsl~~~"
        # wsl system configs
        sudo rsync -r etc/win10/wsl.conf /etc/wsl.conf     # wsl config, i.e. default user and disk priviledge
        # v2ray
        cp ~/.local/etc/pac.txt /mnt/c/MY_SOFTWARE/v2rayN-windows-64/v2rayN-Core-64bit/pac.txt

        # typora config
        cp ~/.local/etc/typora/owen-auto-number.css /mnt/c/Users/$WinUserName/AppData/Roaming/Typora/themes/owen-auto-number.css 
        TYPORA_CSS_REF='@import "owen-auto-number.css";    /* owen config */'
        TYPORA_THEME_FILE="/mnt/c/Users/$WinUserName/AppData/Roaming/Typora/themes/github.css"
        sudo sed -i '/owen config/d' $TYPORA_THEME_FILE
        sudo sed -i "1s:^:$TYPORA_CSS_REF\n:" $TYPORA_THEME_FILE

        # cp to 
        mkdir -p /mnt/d/.local/ && rsync -r etc/win10/* /mnt/d/.local/win10

        powershell.exe -File '.\bootstrap-win.ps1'
    fi

    # do compiler
    # ahk

    # -- zsh config ---------------------------------------------------------
    try_config ~/.zshrc "source ~/.local/etc/zsh.conf"

    # -- tmux config ---------------------------------------------------------
    try_config ~/.tmux.conf "source ~/.local/etc/tmux.conf"
}

main $@


