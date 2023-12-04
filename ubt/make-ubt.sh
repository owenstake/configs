#!/usr/bin/bash
source lib.sh
ScriptDir=$(realpath $(dirname $0))

function AddHookToConfigFile() {
    local file="$1"
    local msg="$2"
    local commentMarker=${3:-"#"}
    local MarkLine="$commentMarker owen configed" 
    local line="${msg} ${MarkLine}"

    # touch file and mkdir -p
    if [ ! -e "$file" ]; then
        mkdir -p $(dirname $file)
        touch $file
    fi

    # check if config item is already in config file
    local itemNum=$(grep -c -F "$MarkLine" $file)
    case $itemNum in
	    0)
            fmt_info "Add config item to $file"
            echo "$line" >> $file
            ;;
	    1)
            fmt_info "Update config item in $file"
            lineNum=$(grep -n "$MarkLine" $file | cut -d':' -f1)
            sed -i "$lineNum c $line" $file
            ;;
	    *)
            fmt_error "Fail to update owen config in $file"
            fmt_error "There are more then one line exists in $file"
        ;;
    esac
}

function DeployConfigDir() {
    local srcDir=$1
    local dstDir=$2
    mkdir -p $dstDir
    rsync -r $srcDir/* $dstDir
    fmt_info "DeployConfigDir $srcDir to $dstDir"
}

function DeployConfigFile() {
    local srcFile=$1
    local dstFile=$2
    fmt_info "DeployConfigFile $srcFile to $dstFile"
    mkdir -p $(dirname $dstFile)
    rsync $srcFile $dstFile
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

    DeployConfigDir   etc/keymap        $OwenInstallDir/etc/keymap/
    DeployConfigDir   bin               $OwenInstallDir/bin

    if [ -f ../common/etc/init-in-one.lua ] ; then
        DeployConfigFile ../common/etc/init-in-one.lua \
                            ~/.config/nvim/init.lua
    fi

    # echo "export PATH=$PATH:$OwenInstallDir/bin" >> ~/.profile

    # xbindkeys config
    if command_exists xbindkeys; then
	DeployConfigFile etc/keymap/xbindkeysrc ~/.xbindkeysrc
    fi

    # xmodmap config
    if command_exists xmodmap; then
	DeployConfigFile etc/keymap/xmodmap ~/.Xmodmap
    fi

    # Generate ssh config file
    if [[ $(uname -a) == *WSL* ]] ; then
        fmt_info "Generate ssh config and install"
        jsonConfig=$(find .. -name "proxy.json" -exec realpath {} \;)
        if [[ -z $jsonConfig ]] ; then
            fmt_error "No found file proxy.json"
        else
            SearchAndExecFile \
                ".." \
                "sshconfig.py" \
                $jsonConfig \
                $OwenInstallDir/etc/ssh/config
        fi
    fi

    fmt_info "-- Deploy hooks to config file ---------"
    AddHookToConfigFile   \
	    ~/.vimrc      \
	    "source $OwenInstallDir/etc/vim/vimrc"   '"'
    AddHookToConfigFile   \
	    ~/.zshrc      \
	    "source $OwenInstallDir/etc/zsh/zshrc"
    AddHookToConfigFile   \
	    ~/.tmux.conf  \
	    "source $OwenInstallDir/etc/tmux/tmux.conf"
    AddHookToConfigFile   \
	    ~/.ssh/config \
	    "Include $OwenInstallDir/etc/ssh/config"
    AddHookToConfigFile   \
	    ~/.profile    \
	    "[ -d $OwenInstallDir/bin ] && PATH=\"$OwenInstallDir/bin:\$PATH\""

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

