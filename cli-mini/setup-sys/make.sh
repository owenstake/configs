#!/usr/bin/bash

scriptDir=$(dirname $0)

if [ -z $scriptDir ]; then
    fmt_error "\$scriptDir is None"
    exit 1
fi

# global var
subdir=(bin etc repo)
buildDir=$scriptDir/output
mkdir -p $buildDir

InstallDir="$HOME/z/.dotfile"
mkdir -p $InstallDir

source lib.sh  # dep on $InstallDir

# ./make all should not polute other dir but itself.
MakeCliMini() {
    # make -p
    fmt_info "Construct buildDir"
    for d in "${subdir[@]}"; do
        fmt_info "make dir $buildDir/$d"
        mkdir -p $buildDir/$d
    done

    fmt_info "Generate bashrc for tmux"
    local bashrc_for_tmux=$(GetBashrcForTmux $InstallDir )
    echo "$bashrc_for_tmux" > $InstallDir/etc/bashrc  # hook in tmux conf

    fmt_info "Generate tmux config"
    local tmuxConfig=$(GetTmuxConfig )
    echo "$tmuxConfig" > $buildDir/etc/tmux.conf

    Set_all_proxy
    if [ $? -ne 0 ]; then
        fmt_error "Set all_proxy fail!"
        return 1
    fi

    if ! curl -s www.google.com --connect-timeout 3 > /dev/null; then
        fmt_error "Proxy fail. Please check proxy port 10809."
        fmt_error "1. SSH login from wsl ? Exec in wsl: ssh $(whoami)@xx"
        fmt_error "2. SSH remote forward is set ?"
        fmt_error "3. WSL proxy is ok ? Exec in wsl: curl www.google.com"
        fmt_error "4. WIN proxy is ok for 10809 ?"
        fmt_error "5. WIN firewall is opened for wsl? If not, try the following command in powershell."
        fmt_error '   sudo Set-NetFirewallProfile -DisabledInterfaceAliases "vEthernet (WSL)".'
        exit 1
    else
        # distro-irrelevant 
        fmt_info "Proxy ok."
        # fzf. build bin file need github.
        zlua_config download $buildDir/repo
        fzf_config  download $buildDir/repo
        cli_tool_download $buildDir/bin
    fi
}

MakeInstall() {
    fmt_info "Construct install dir"
    fmt_info "Deploy file"
    # for d in ${subdir[@]}; do
    #     mkdir -p $InstallDir/$d
    #     DeployConfigDir  $buildDir/$d  $InstallDir/$d
    # done
    DeployConfigDir  $buildDir  $InstallDir

    fmt_info "Write config to file"
    # vim config
    if [ ! -e ~/.vimrc ] || ! grep -q "inoremap jk"  ~/.vimrc ; then
        local vim_config="inoremap jk <esc>"
        echo "$vim_config" >> ~/.vimrc
        # echo "$vim_config" >> ~/.vimrc
    fi

    fmt_info "Add hook to config file"
    # hook tmux
    AddHookToConfigFile    \
        ~/.tmux.conf       \
        "source $InstallDir/etc/tmux.conf"
    # hook vim
    AddHookToConfigFile    \
        ~/.config/nvim/init.vim       \
        "source $InstallDir/etc/init.vim"

    fmt_info "Custom app install"
    zlua_config install
    fzf_config  install
    return
}

MakeClean() {
    if [ ! -e "$buildDir" ]; then
        fmt_error "\$buildDir is no exists"
        return
    fi
    fmt_info "Clean build dir $buildDir"
    rm -r $buildDir
    return
}

MakeUninstall() {
    if [ ! -e "$InstallDir" ]; then
        fmt_error "\$InstallDir is none!"
        return 1
    fi
    fmt_info "Delete Hook in config file"
    DeleteHookInConfigFile ~/.tmux.conf
    DeleteHookInConfigFile ~/.config/nvim/init.vim

    fmt_info "Clean install dir $InstallDir"
    rm -r $InstallDir
    return
}

main() {
    target=${1:-"all"}
    case $target in
        install)
            fmt_info "Installing ~~"
            MakeInstall
            ;;
        uninstall)
            fmt_info "Uninstalling ~~"
            MakeUninstall
            ;;
        clean)
            fmt_info "Cleaning ~~"
            MakeClean
            ;;
        all)
            fmt_info "Building ~~"
            MakeCliMini
            ;;
        *)
            fmt_error "unknown target $1"
            ;;
    esac
}

main "$@"
