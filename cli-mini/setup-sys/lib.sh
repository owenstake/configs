export OwenInstallDir="$HOME/.dotfile"  # used in ranger

FMT_RED=$(printf '\033[31m')
FMT_GREEN=$(printf '\033[32m')
FMT_YELLOW=$(printf '\033[33m')
FMT_BLUE=$(printf '\033[34m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

fmt_info() {
    printf '%sINFO: %s%s\n' "${FMT_GREEN}${FMT_BOLD}" "$*" "$FMT_RESET"
}

fmt_warn() {
    printf '%sWARN: %s%s\n' "${FMT_YELLOW}${FMT_BOLD}" "$*" "$FMT_RESET"
}

fmt_error() {
    printf '%sERRO: [%s] %s%s\n' "${FMT_RED}${FMT_BOLD}" "$funcstack[2] $@" "$@" "$FMT_RESET"  1>&2
}

GetTmuxConfig() {
	tmux_base_config="
		# configed
        # set -g default-terminal xterm  # to fix ctrl-L in tmux3.2
		setw -g mode-keys vi # hjkl move in copy mode

		bind h select-pane -L
		bind j select-pane -D
		bind k select-pane -U
		bind l select-pane -R
		bind - split-window -v
		bind tab last-window

		set -g base-index 1
		setw -g pane-base-index 1
		set-option -g default-command 'TMOUT=0 bash --rcfile $InstallDir/etc/bashrc'
		set-option -g allow-rename off
	"

	tmux18_extra_config="
		set -g mode-mouse on         # tmux1.8
		set -g mouse-resize-pane on  # tmux1.8
		set -g mouse-select-pane on  # tmux1.8
		set -g mouse-select-window   # tmux1.8
		set -g window-status-current-bg yellow   # tmux1.8
	"

	tmux32a_extra_config="
		set -g mouse on
		set-window-option -g window-status-current-style bg=yellow

        set -g window-status-last-style fg=yellow,bold

        bind-key -T copy-mode-vi 'v' send -X begin-selection     # Begin selection in copy mode.
        bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle  # Begin selection in copy mode.
        bind-key -T copy-mode-vi 'y' send -X copy-selection      # Yank selection in copy mode.
	"
	local tmux_version=$(tmux -V | cut -d' ' -f2)
	case $tmux_version in
		1.8)
			local tmux_config="${tmux_base_config} ${tmux18_extra_config}"
			;;
		2.8)
			local tmux_config="${tmux_base_config} ${tmux32a_extra_config}"
			;;
		3.2a)
			local tmux_config="${tmux_base_config} ${tmux32a_extra_config}"
			;;
		*)
			fmt_error "Unknow tmux version"
			return -1
			;;
	esac
    echo "$tmux_config"
}

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

SearchAndExecFileWithCallback() {
    local process="${1:-}"
    local dirname=$(realpath $2)
    local fileName=$3

    if [[ -z $dirname ]] ; then
        echo "Env dirname $dirname is null"
        return -1
    fi

    local foundFile=$(find $dirname -name $fileName)
    if [[ 0 == $? ]] ; then
        if [[ -z $foundFile ]] ; then
            echo "No found file $fileName"
        else
            $process $foundFile ${@:4:$#}
            return $?
        fi
    else
        echo "Search failed"
    fi
}

SearchAndExecFile() {
    SearchAndExecFileWithCallback "" $@
}

ExecOwenFile() {
    SearchAndExecFileWithCallback "" $OwenInstallDir $@
    return $?
}

InWsl() {
    [[ $(uname -a) == *WSL* ]]
    return $?
}

InOs() {
    local name=$1
    local curOsName=$(grep "^ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    [ "${name,,}" = "${curOsName,,}" ]   # ,, is for low-case
    return $?
}

InUos() {
    InOs "uos"
}

InCentos() {
    InOs "centos"
}

GetCurOsName() {
    local curOsName=$(grep -w "^ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    echo ${curOsName,,}
}

GitClone() {
    # local url=$1
    git clone --quiet --depth 1 $@
}

# function
AddHookToConfigFile() {
	local file="$1"
	local msg="$2"
	local commentMarker=${3:-"#"}
	local MarkLine="$commentMarker asdf configed"
    local line="${msg} ${MarkLine} $(date +'%Y-%m-%d %H:%M:%S')"

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

DeleteHookInConfigFile() {
	local file="$1"
	local msg="$2"
	local MarkLine="asdf configed"

	# touch file and mkdir -p
	if [ ! -e "$file" ]; then
		mkdir -p $(dirname $file)
		touch $file
	fi

	# check if config item is already in config file
	local itemNum=$(grep -c -F "$MarkLine" $file)
	case $itemNum in
		0)
			fmt_info "No hook item found in $file"
			;;
		1)
			fmt_info "Remove one hook item in $file"
			lineNum=$(grep -n "$MarkLine" $file | cut -d':' -f1)
			sed -i "$lineNum d" $file
			;;
		*)
			fmt_error "There are more then one hook line exists in $file, "\
                        "please remove them manually"
            ;;
	esac
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

try_get_download_url() {
    local type=$1
    local release_info=$2
    local file_pattern=$3
    local ext_pattern="(t.*[xg]z|zip)"  # match .tar.gz .tar.xa .tgz
    case $type in
        rust)
            local cpu_arch=$(uname -m)
            # TODO: need support linux-gnu ? Too complicated.
            local basename_pattern="${cpu_arch}-unknown-linux-musl"
            ;;
        golang)
            local cpu_arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
            local basename_pattern="linux[-_]${cpu_arch}"
            ;;
        *)
            fmt_error "unknown type $type"
            return 1
    esac
    file_pattern=${file_pattern:-"${basename_pattern}.${ext_pattern}$"}
    local dl_url=$(echo "$release_info" | jq -r '.assets[] | select(.name |
                        match("'$file_pattern'")).browser_download_url'  )
    if [ $? -ne 0 ] || [ -z "$dl_url" ]; then
        fmt_error "Get dl_url fail, file_pattern match nothing"
        return 1
    else
        echo "$dl_url"  # output
    fi
    return
}

base_app_bin_download() {
    local language=$1
    local bin_name=$2
    local repo_name=$3
    local dst_dir=$4
    local file_pattern=$5
    fmt_info "Download $bin_name in $file_pattern from $repo_name"
    local GITHUB_API_REMAIN_COUNTS=$(curl -sf https://api.github.com/rate_limit \
                                                | jq '.rate.remaining')
    if [ $GITHUB_API_REMAIN_COUNTS -lt 30 ]; then
        fmt_info "Github API count has be exhausted with remaining $GITHUB_API_REMAIN_COUNTS,"\
                    "use github token to download instead."
        if [ -z $GITHUB_TOKEN ]; then
            fmt_error "Fail to curl github API. Please set GITHUB_TOKEN into env"
            return 1
        else
            local CURL_OPTION="--header \"Authorization: Bearer $GITHUB_TOKEN\""
            local GITHUB_API_TOKEN_REMAIN_COUNTS=$(eval curl -sf https://api.github.com/rate_limit \
                                        $CURL_OPTION | jq '.rate.remaining')
            fmt_info "Github API token counts remains $GITHUB_API_TOKEN_REMAIN_COUNTS."
        fi
    fi

    local release_info=$(eval curl -sf $CURL_OPTION https://api.github.com/repos/$repo_name/releases/latest)
    if [ $? -ne 0 ] ; then
        fmt_error "Curl github api fail"
        return 1
    fi
    if [ -z "$release_info" ] ; then
        fmt_error "Curl github api ok, but release_info is null"
        return 1
    fi
    # fmt_error "release_info is $release_info" 2>&1 | head -n5
    local dl_url=$(try_get_download_url "$language" "$release_info" "$file_pattern")
    if [ $? -ne 0 ] ; then
        fmt_error "dl_url get fail $dl_url "
        return 1
    fi

    local dl_file=${dl_url##*/}
    # local dl_dir=${dl_tgz%%.tar.gz}
    # fmt_info "Download from $dl_url"
    # fmt_info "Retrieve $dl_dir/$bin_name from download url"
    # fmt_info "Deploy bin to $InstallDir/bin"
    # local dst_dir="$buildDir/bin"
    fmt_info "Download url is $dl_url"
    # dl_file_ext=${dl_file#*.}
    case $dl_file in
        *.tar.[xg]z | *.tgz )
            # Get final part of filename splitted by "."
            local zipMethod=${dl_file: -2}  # get last two charactors
            # default local array
            declare -A zipMapOption=([gz]="--gzip" [xz]="--xz")
            local option=${zipMapOption[$zipMethod]}
            if [ -z "$option" ]; then
                fmt_error "unknown zipMethod $zipMethod"
                return
            fi
            curl -sL $dl_url | tar -x $option -C $dst_dir \
                                    --transform='s%.*/%%' \
                                    --no-anchor "$bin_name"
            ;;
        *.gz)
            local bin_file="$buildDir/bin/$bin_name"
            curl -sL $dl_url | gunzip -c > $bin_file && chmod +x $bin_file
            ;;
        *.zip)
            tmpfile=$(mktemp)
            curl -sL $dl_url -o $tmpfile && 
                    unzip -qjo $tmpfile "**/$bin_name" -d $dst_dir &&
                    rm $tmpfile
            ;;
        *)
            fmt_error "unknow ext decompress for $dl_file"
            ;;
    esac
}


cargo_app_bin_download() {
    base_app_bin_download "rust" "${@}" 
    return $?
}

golang_app_bin_download() {
    base_app_bin_download "golang" "${@}"
    return $?
}

golang_apps_download() {
    local dst_dir=$1
    golang_app_bin_download "cloudpan189-go" "tickstep/cloudpan189-go" "$dst_dir"
    golang_app_bin_download "lazygit"        "jesseduffield/lazygit"   "$dst_dir" "Linux_x86_64.tar.gz$"
    golang_app_bin_download "lf"             "gokcehan/lf"             "$dst_dir"
}

rust_tools_download() {
    cargo_app_bin_download "cargo-binstall"  "cargo-bins/cargo-binstall" "$buildDir/bin"
    local cpu_arch=$(uname -m)
    $buildDir/bin/cargo-binstall -y --no-discover-github-token  \
                    --disable-strategies compile                \
                    --targets "${cpu_arch}-unknown-linux-musl"  \
                    --targets "${cpu_arch}-unknown-linux-gnu"   \
                    --install-path $buildDir/bin                \
                    bat fd-find ripgrep zoxide eza              \
                    bandwhich bottom difftastic du-dust         \
                    fselect git-delta grex hexyl hyperfine      \
                    jless joshuto lsd mcfly                     \
                    procs rm-improved sd starship tealdeer      \
                    tokei watchexec-cli wthrr
    return
}

cli_tool_download() {
    local dst_dir=$1
    golang_apps_download $dst_dir
    rust_tools_download  $dst_dir
}

fzf_config() {
    local action=${1}
    local fzf_dir=${2}
    case "$action" in
        download)
            if [[ ! -e "$fzf_dir" ]]; then
                # make
                fmt_info "Download fzf through proxy"
                git clone --quiet --depth 1 https://github.com/junegunn/fzf.git $fzf_dir
                # --all for set short-cut <ctrl-t> <ctrl-r>
                # make install
            else
                fmt_info "Skip download fzf, $fzf_dir is already exists, "
            fi
            ;;
        install)
            fmt_info "Install fzf through proxy"
            local foundFile=$(search_file $InstallDir "**/fzf/install")
            eval "$foundFile --all --no-update-rc --xdg"
            ;;
        *)
            fmt_error "unknown action $action"
            return
            ;;
    esac
}

zlua_config() {
    local zlua_dir="$buildDir/repo/zlua"
    # local zlua_install_dir="$InstallDir/repo/zlua"
    # make
    action=${1}
    case $action in
        download)
            fmt_info "Download zlua"
            if [[ ! -e $zlua_dir ]]; then
                git clone --quiet --depth 1 https://gitee.com/mirrors/z.lua.git \
                        $zlua_dir                                               \
                        && rm -rf $_/.git
            fi
            ;;
        install)
            fmt_info "Install zlua"
            # bashrc config already
            ;;
        *)
            fmt_error "unknown action $action"
            ;;
    esac
    return
}

set_all_proxy() {
    local os_release=$(cat /etc/os-release | grep -xoP 'ID=\K.*' | tr -d '"')
    local proxy_server_address
    if [ -n "$all_proxy" ]; then
        fmt_info "Env all_proxy is configed already."
    else
        case $os_release in
            centos)
                proxy_server_address=http://127.0.0.1:10809
                ;;
            uos)
                proxy_server_address=http://127.0.0.1:20171
                ;;
            ubuntu)
                if InWsl ; then
                    proxy_server_address=http://$WINIP:10809
                else
                    proxy_server_address=http://127.0.0.1:20171
                fi
                ;;
            *)
                fmt_error "Unknown system type $os_release"
                return 1
                ;;
        esac
        fmt_info "Env all_proxy set to $proxy_server_address"
        export all_proxy=$proxy_server_address
    fi
}

GetBashrcForTmux() {
    if [ -z "$1" ] ; then
        fmt_error "InstallDir is null"
        return 1
    fi
    local InstallDir=$1
    local bashrc_for_tmux="
        export EDITOR=vim # configed
        source ~/.bashrc
        # export PATH=\$PATH:\$HOME/.cargo/bin
        export PATH=\$PATH:$InstallDir/bin
        alias vim='nvim'
        alias rp='realpath'
        alias zc='z -c'
        alias zb='z -b'
        alias zf='z -I'
        alias reboot='echo reboot use \\reboot'
        # tmux
        alias ta='tmux a'
        alias tn='tmux new -s'
        alias tk='tmux kill-session -t'
        alias tls='tmux ls'
        alias tat='tmux a -t'
        alias tmuxc='vim ~/.tmux.conf'
        alias tmuxs='tmux source ~/.tmux.conf'
        rgf () {
            rg --color=always --line-number --no-heading             \\
                --smart-case '\${*:-}' |                             \\
                fzf --ansi                                           \\
                --color 'hl:-1:underline,hl+:-1:underline:reverse'   \\
                --delimiter : --preview 'bat --color=always {1}      \\
                --highlight-line {2}'                                \\
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'  \\
                --bind 'enter:become(vim {1} +{2})'
        }
        eval \"\$(lua $(search_file $InstallDir z.lua) --init bash)\"
        [ -f ~/.config/fzf.bash ] && source ~/.config/fzf.bash
    "
    echo "$bashrc_for_tmux"
    return
}

search_base() {
    local search_type=$1
    local dir_been_search=$2
    local file_pattern=$3
    if [ -z "$file_pattern" ] ; then
        fmt_error "Empty file_pattern. Dir is $dir_been_search"
        return 1
    fi
    if ! echo "$file_pattern" | grep -q / ; then
        file_pattern="**/$file_pattern"
    fi
    local rst=$(find "$dir_been_search" -wholename "$file_pattern" \
                                        -type ${search_type:0:1})
    if [ -z "$rst" ] ; then
        fmt_error "Can not find $search_type by $file_pattern in dir $dir_been_search"
        return 1
    fi
    if [ 1 -ne $(echo "$rst" | wc -l) ] ; then
        fmt_warn "Find multi $search_type by $file_pattern in dir $dir_been_search"
    fi
    echo "$rst" | head -n1
    return
}

search_file() {
    search_base "file" "${@}"
    return $?
}

search_dir() {
    search_base "dir" "${@}"
    return $?
}

search_config_file() {
    search_file $InstallDir/etc "${@}"
    return $?
}

