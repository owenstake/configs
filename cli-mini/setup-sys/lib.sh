
GetTmuxConfig() {
	tmux_base_config="
		# configed
		bind h select-pane -L
		bind j select-pane -D
		bind k select-pane -U
		bind l select-pane -R
		bind - split-window -v
		bind tab last-window

		set -g base-index 1
		setw -g pane-base-index 1
		setw -g mode-keys vi
		set-option -g default-command 'TMOUT=0 bash --rcfile $InstallDir/etc/bashrc'
		set-option -g allow-rename off
	"

	tmux18_extra_config="
		set -g mode-mouse on         # tmux1.8
		set -g mouse-resize-pane on  # tmux1.8
		set -g mouse-select-pane on  # tmux1.8
		set -g mouse-select-window   # tmux1.8
		set -g window-status-current-bg white   # tmux1.8
	"

	tmux32a_extra_config="
		set -g mouse on
		set-window-option -g window-status-current-style bg=yellow
	"
	local tmux_version=$(tmux -V | cut -d' ' -f2)
	case $tmux_version in
		1.8)
			local tmux_config="${tmux_base_config} ${tmux18_extra_config}"
			;;
		3.2a)
			local tmux_config="${tmux_base_config} ${tmux32a_extra_config}"
			;;
		*)
			fmt_error "Unknow tmux version"
			return -1
			;;
	esac
}

# function
AddHookToConfigFile() {
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

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

setup_log_color() {
    FMT_RED=$(printf '\033[31m')
    FMT_GREEN=$(printf '\033[32m')
    FMT_YELLOW=$(printf '\033[33m')
    FMT_BLUE=$(printf '\033[34m')
    FMT_BOLD=$(printf '\033[1m')
    FMT_RESET=$(printf '\033[0m')
}

fmt_info() {
    printf '%sINFO: %s%s\n' "${FMT_GREEN}${FMT_BOLD}" "$*" "$FMT_RESET"
}

fmt_error() {
    printf '%sERRO: [%s] %s%s\n' "${FMT_RED}${FMT_BOLD}" "$funcstack[2] $@" "$@" "$FMT_RESET"  1>&2
}

DeployConfigDir() {
	local srcDir=$1
	local dstDir=$2
	mkdir -p $dstDir
	rsync -r $srcDir/* $dstDir
	fmt_info "DeployConfigDir $srcDir to $dstDir"
}

DeployConfigFile() {
	local srcFile=$1
	local dstFile=$2
	fmt_info "DeployConfigFile $srcFile to $dstFile"
	mkdir -p $(dirname $dstFile)
	rsync $srcFile $dstFile
}
