#!/usr/bin/bash
source lib.sh

ScriptDir=$(realpath $(dirname $0))

export OwenInstallDir="$HOME/.dotfiles"  # used in ranger

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
    DeployConfigDir   etc/ranger     $HOME/.config/ranger/
    DeployConfigDir   etc/fzf        $HOME/.config/fzf/

    # local config
    # DeployConfigDir   ../common/etc/vim ~/.config/vim
    DeployConfigDir   ../common/etc/vim   $OwenInstallDir/etc/vim/
    DeployConfigDir   etc/tmux            $OwenInstallDir/etc/tmux/
    DeployConfigDir   etc/zsh             $OwenInstallDir/etc/zsh/
    DeployConfigDir   etc/newsboat        $OwenInstallDir/etc/newsboat/
    DeployConfigDir   scripts             $OwenInstallDir/scripts

    fmt_info "-- Deploy hooks to config file ---------"
    AddHookToConfigFile   ~/.vimrc       "source $OwenInstallDir/etc/vim/vimrc"   '"'
    AddHookToConfigFile   ~/.zshrc       "source $OwenInstallDir/etc/zsh/zshrc"
    AddHookToConfigFile   ~/.tmux.conf   "source $OwenInstallDir/etc/tmux/tmux.conf"

    if [[ $(uname -a) == *WSL* ]] ; then
        fmt_info "Generate ssh config and install"
        jsonConfig=$(find .. -name "proxy.json" -exec realpath {} \;)
        if [[ -z $jsonConfig ]] ; then
            fmt_error "No found file proxy.json"
        else
            SearchAndExecFile ".." "sshconfig.py" $jsonConfig
        fi
    fi

    ### Force echo to zsh tmux config file
    # if [[ $1 = "f" ]]; then
    #     _owen_force_update=1
    #     fmt_info "Force update config files including zsh,tmux"
    #     fmt_info "You must take care of the duplicated term in zsh/tmux config file~~~"
    #     fmt_info "zsh  $(realpath ~/.zshrc)"
    #     fmt_info "tmux $(realpath ~/.tmux.conf)"
    # else
    #     _owen_force_update=
    # fi

    # WSL config.
    if [[ $(uname -a) == *WSL* ]]; then
        fmt_info "We are in wsl~~~"
        # powershell.exe -c "../win/make-win.ps1 install"
    fi

}

function main() {
    action=${1:-"install"}
    case $action in  
        install)  
            fmt_info "Installing ~~"  
            MakeInstall
            ;;  
        uninstall)  
            fmt_info "Uninstalling ~~"  
            ;;  
        clean)  
            fmt_info "Cleaning ~~"
            ;;
        all)  
            fmt_info "Cleaning ~~"
            ;;
        *)
            fmt_error "unknown action $1"
    esac
}

main $@

