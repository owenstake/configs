#!/usr/bin/bash
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
source lib-cli.sh
source lib-ui.sh

set -e   # exit bash script when cmd fail

fmt_info "This script depends on jq, unzip"

scriptDir=$(realpath $(dirname $0))

# global var
subdir=(bin etc repo)
buildDir=$scriptDir/output
mkdir -p $buildDir

InstallDir="$HOME/.dotfile"
mkdir -p $InstallDir

Make() {  # should not polute the file outside this dir
    fmt_info "Construct buildDir"
    for d in "${subdir[@]}"; do
        fmt_info "make dir $buildDir/$d"
        mkdir -p $buildDir/$d
    done
    # Cli tool bin install

    fmt_info "Construct $buildDir/etc"
    DeployConfigDir  ../common/etc  "$buildDir/etc"
    DeployConfigDir  etc            "$buildDir/etc"
    if InWsl ; then
        generate_ssh_config_file $InstallDir/etc/ssh/sshconfig
    fi

    fmt_info "Construct $buildDir/repo"
    zlua_config     download "$buildDir/repo/zlua"
    fzf_config      download "$buildDir/repo/fzf"
    ohmytmux_config download "$buildDir/repo/ohmytmux"
    if InWsl || InUos ; then
        ohmyzsh_config  download "$buildDir/repo/ohmyzsh"
        zplug_config    download "$buildDir/repo/zplug"
    fi

    fmt_info "Construct $buildDir/bin"
    DeployConfigDir    bin "$buildDir/bin"
    cli_tool_download  "$buildDir/bin"

    if InWsl || InUos ; then
        InstallNodejs
        InstallWudaoDict $InstallDir/repo/wudaoDict
        InstallGolang
    fi
    if InUos ; then
        InstallV2rayA
    fi
    # install v2rayA
    set_all_proxy
    test_connectivity_to_google # check network proxy

    return
}

MakeClean() {
    if [ ! -e "$buildDir" ]; then
        fmt_error "\$buildDir is no exists"
        return
    fi
    fmt_info "Clean build dir $buildDir"
    rm -r --interactive=never $buildDir
    return
}

MakeInstall() {
	## override config
	# mkdir -p ~/.local $$ mkdir -p ~/.config
	fmt_info "Make install. Copy $buildDir to $InstallDir"
    DeployConfigDir  "$buildDir"  "$InstallDir"

	fmt_info "Write InstallDir path to InstallDir.sh"
    local foundFile=$(search_config_file "InstallDir.sh")
    if [ $? -eq 0 ] ; then
        AddHookToConfigFile   \
            "$foundFile"      \
            "export InstallDir=$InstallDir"
    else
        fmt_error "No found file InstallDir.sh"
        return 1
    fi

    fmt_info "Install fzf"
	DeployConfigDir   etc/fzf       $HOME/.config/fzf/
    fzf_config install

    fmt_info "Install zlua"
    zlua_config install

    fmt_info "Install ohmytmux"
    ohmytmux_config install "$InstallDir/repo/ohmytmux"

    if InWsl || InUos ; then
        fmt_info "Override config file which can not be specified"
        DeployConfigDir   etc/ranger    $HOME/.config/ranger/
        DeployConfigDir   etc/newsboat    $HOME/.config/newsboat/
        if [ -f ../common/etc/init-in-one.lua ] ; then
            DeployConfigFile ../common/etc/init-in-one.lua \
                                ~/.config/nvim/init.lua
        fi
        fmt_info "Install ohmyzsh"
        ohmyzsh_config install

        fmt_info "Install zplug"
        zplug_config   install "$InstallDir/repo/zplug"
    fi

    # TPM is already in oh my tmux 
    # fmt_info "Install tmux-tpm"
    # InstallTmuxTPM  $XDG_CONFIG_HOME/tmux/plugins/tpm

	# xbindkeys config
	if InUos ; then
        fmt_info "Config keymap"
		# keybind only for no-wsl. wsl already has win ahk for keybind.
		if command_exists xbindkeys; then
            local foundFile=$(search_config_file  "xbindkeysrc")
			DeployConfigFile $foundFile ~/.xbindkeysrc
		fi

		# xmodmap config
		if command_exists xmodmap; then
            local foundFile=$(search_config_file  "xmodmap")
			DeployConfigFile $foundFile ~/.Xmodmap
		fi
	fi

	fmt_info "-- Deploy hooks to config file ---------"
    if InWsl || InUos ; then
        local foundFile=$(search_config_file "vimrc")
        AddHookToConfigFile    \
            ~/.vimrc           \
            "source $foundFile"   '"'

        AddHookToConfigFile   \
            ~/.zshenv         \
            "export ZDOTDIR=\$HOME/.config/zsh"

        local foundFile=$(search_config_file "zshrc")
        AddHookToConfigFile   \
            ~/.config/zsh/.zshrc      \
            "source $foundFile"
    fi

    local foundFile1=$(search_file $InstallDir ".tmux.conf.local")
    local foundFile2=$(search_config_file "tmux.conf")
    cat "$foundFile1" "$foundFile2" > "$XDG_CONFIG_HOME/tmux/tmux.conf.local"  

    if InCentos ; then
        local foundFile=$(search_file $InstallDir "bashrc")
        local tmux_extra_config="set-option -g default-command 'TMOUT=0 bash --rcfile $foundFile'"
        echo "$tmux_extra_config" >> "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
    fi

	# AddHookToConfigFile   \
	# 	"$XDG_CONFIG_HOME/tmux/tmux.conf.local"  \
	# 	"source $foundFile2"

	# WSL config.
    if InWsl ; then
        local foundFile=$(search_config_file  "sshconfig")
        AddHookToConfigFile   \
            ~/.ssh/config \
            "Include $foundFile"
		fmt_info "We are in wsl~~~"
    fi

	# AddHookToConfigFile   \
	# 	~/.profile    \
	# 	"[ -d $InstallDir/bin ] && PATH=\"$InstallDir/bin:\$PATH\""
}

MakeUninstall() {
    if [ ! -e "$InstallDir" ]; then
        fmt_error "\$InstallDir is none!"
        return 1
    fi
    fmt_info "Delete Hook in config file at ${ConfigFile[@]}"
    local ConfigFile=(~/.zshrc ~/.vimrc ~/.tmux.conf ~/.ssh/config ~/.profile)
    for f in "${ConfigFile[@]}"; do
        DeleteHookInConfigFile "$f"
        # DeleteHookInConfigFile ~/.config/nvim/init.vim
    done

    fmt_info "Clean install dir $InstallDir"
    rm -r --interactive=never $InstallDir
    return
}

main() {
	action=${1:-"all"}
	case $action in
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
			fmt_info "Make ~~"
			Make
			;;
		*)
			fmt_error "Unknown action $1"
	esac
}

main $@

