#!/usr/bin/bash
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
source lib-cli.sh
source lib-ui.sh

set -e   # exit bash script when cmd fail

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

    fmt_info "Construct $buildDir/repo"
    zlua_config     download "$buildDir/repo/zlua"
    fzf_config      download "$buildDir/repo/fzf"
    ohmytmux_config download "$buildDir/repo/ohmytmux"

    fmt_info "Construct $buildDir/bin"
    DeployConfigDir    bin "$buildDir/bin"
    cli_tool_download  "$buildDir/bin"

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
    rm -r $buildDir
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

	fmt_info "Override config file which can not be specified"
	if [ -f ../common/etc/init-in-one.lua ] ; then
		DeployConfigFile ../common/etc/init-in-one.lua \
							~/.config/nvim/init.lua
	fi
    fmt_info "Install fzf"
	DeployConfigDir   etc/fzf       $HOME/.config/fzf/
    fzf_config install

    fmt_info "Install zlua"
    zlua_config install

    fmt_info "Install ohmytmux"
    ohmytmux_config install "$InstallDir/repo/ohmytmux"

	fmt_info "-- Deploy hooks to config file ---------"
    local foundFile=$(search_config_file "tmux.conf")
	AddHookToConfigFile   \
		"$XDG_CONFIG_HOME/tmux/tmux.conf.local"  \
		"source $foundFile"
}

MakeUninstall() {
    if [ ! -e "$InstallDir" ]; then
        fmt_error "\$InstallDir is none!"
        return 1
    fi
    fmt_info "Delete Hook in config file at ${ConfigFile[@]}"
    local ConfigFile=(~/.tmux.conf)
    for f in "${ConfigFile[@]}"; do
        DeleteHookInConfigFile "$f"
        # DeleteHookInConfigFile ~/.config/nvim/init.vim
    done

    fmt_info "Clean install dir $InstallDir"
    rm -r $InstallDir
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

