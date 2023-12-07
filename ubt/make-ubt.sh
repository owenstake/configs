#!/usr/bin/bash
source lib.sh
ScriptDir=$(realpath $(dirname $0))

MakeInstall() {
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
	if ! InWsl ; then
		# keybind only for no-wsl. wsl already has win ahk for keybind.
		if command_exists xbindkeys; then
			DeployConfigFile etc/keymap/xbindkeysrc ~/.xbindkeysrc
		fi

		# xmodmap config
		if command_exists xmodmap; then
			DeployConfigFile etc/keymap/xmodmap ~/.Xmodmap
		fi
	fi

	# Generate ssh config file
	if InWsl ; then
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

main() {
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

