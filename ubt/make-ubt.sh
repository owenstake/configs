#!/usr/bin/bash
source lib.sh

export WinUserName=$(echo $PATH | sed 's#.*/mnt/c/Users/\([^/]*\)/.*#\1#')
export WinUserHome=/mnt/c/Users/${WinUserName}
export WinUserDownloads=${WinUserHome}/Downloads
export WinUserDesktop=${WinUserHome}/Desktop
export WinUserWeiyun="/mnt/c/Weiyun/Personal"              # used in ranger
export WinUserWeiyunNote="/mnt/c/Weiyun/Personal/my_note"  # used in ranger

function AddHookToConfigFile() {
    local file=$1
    local msg=$2
    local commentMarker=${3:-"#"}
    local MarkLine="$commentMarker owen configed" 
    local line="${msg} ${MarkLine}"
    if ! grep -q "$MarkLine" $file ; then
        fmt_info "owen $file is configing"
        echo "$line" >> $file
        # echo "# -- owen $file config -- "     >> $file
        # echo "$msg"                           >> $file
        # echo "# -- end owen $file config -- " >> $file
    else
        fmt_info "update owen config in $file"
        sed -i "s@.*$MarkLine.*@$line@" $file
    fi
}

function DeployConfigDir() {
    local srcDir=$1
    local dstDir=$2
    mkdir -p $dstDir
    rsync -r $srcDir/* $dstDir
    fmt_info "DeployConfigDir $srcDir to $dstDir"
}

function MakeInstall() {
    ## override config
    # mkdir -p ~/.local $$ mkdir -p ~/.config
    DeployConfigDir   etc/ranger     ~/.config/ranger/
    DeployConfigDir   etc/newsboat   ~/.config/newsboat/
    DeployConfigDir   etc/fzf        ~/.config/fzf/

    # local config
    # DeployConfigDir   ../common/etc/vim ~/.config/vim
    DeployConfigDir   ../common/etc/vim   ~/.local/etc/vim/
    DeployConfigDir   etc/tmux            ~/.local/etc/tmux/
    DeployConfigDir   etc/zsh             ~/.local/etc/zsh/

    # AddHookToConfigFile   ~/.zshrc       "source   ~/.local/etc/zsh.conf"
    # AddHookToConfigFile   ~/.tmux.conf   "source   ~/.local/etc/tmux.conf"
    # AddHookToConfigFile   ~/.vimrc       "source   ~/.local/etc/vim/vimrc"


    # rsync -r etc          ~/.local/
    # rsync -r etc/ranger   ~/.config/
    # rsync -r etc/newsboat ~/.config/
    # rsync -r etc/fzf      ~/.config/
    # rsync -r ../common/etc/vim      ~/.config/
    # ln -sf ~/.local/etc/vim/vimrc ~/.vimrc

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

    # WSL config.
    if uname -r | grep -qi "microsof"; then
        fmt_info "We are in wsl~~~"
        # WSL system configs
        # sudo rsync -r etc/win10/wsl.conf /etc/wsl.conf     # wsl config, i.e. default user and disk priviledge
        # mkdir -p /mnt/d/.local/ && rsync -r etc/win10/* /mnt/d/.local/win10

        # fmt_info 'Install to windows by "../win/make-win.ps1 install"'
        # powershell.exe -c "../win/make-win.ps1 install"
    fi

    fmt_info "-- Deploy hooks to config file ---------"
    AddHookToConfigFile   ~/.zshrc       "source ~/.local/etc/zsh/zsh.conf"
    AddHookToConfigFile   ~/.tmux.conf   "source ~/.local/etc/tmux/tmux.conf"
    AddHookToConfigFile   ~/.vimrc       "source ~/.local/etc/vim/vimrc"   '"'
}

action=${1:-"install"}
case $action in  
    install)  
        echo "Installing ~~"  
        MakeInstall
        ;;  
    uninstall)  
        echo "Uninstalling ~~"  
        ;;  
    clean)  
        echo "Cleaning ~~"
        ;;
    all)  
        echo "Cleaning ~~"
        ;;
    *)
        echo "unknown action $1"
esac

