source lib.sh

scriptDir=$(dirname $0)

InstallDir="$HOME/z/dotfile"
# fzf_dir="$InstallDir/bin"

mkdir -p $InstallDir
mkdir -p $InstallDir/etc
mkdir -p $InstallDir/repo
mkdir -p $InstallDir/bin

mkdir -p $scriptDir/bin

bash_config="
    # configed
    alias ta='tmux a'
    alias tn='tmux new -s'
    alias tk='tmux kill-session -t'
    alias tls='tmux ls'
    alias tat='tmux a -t'
    alias tmuxc='vim ~/.tmux.conf'
    alias tmuxs='tmux source ~/.tmux.conf'
"

bashrc_for_tmux="
    export EDITOR=vim # configed
    source ~/.bashrc
	export PATH=\$PATH:$InstallDir/bin
    alias rp='realpath'
    alias zc='z -c'
    alias zb='z -b'
    alias zf='z -I'
    alias reboot='echo reboot use \\reboot'
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
    eval \"\$(lua $InstallDir/repo/zlua/z.lua --init bash)\"
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
"

vim_config="inoremap jk <esc>"

git_repo_install() {
    local repo_name=$1
    local bin_name=$2
    local dl_url=$(curl -s https://api.github.com/repos/$repo_name/releases/latest |
				jq -r '.assets[] | select(.name |
                        match("x86_64-unknown-linux-musl.*gz$"))
                        .browser_download_url')
    local dl_tgz=${dl_url##*/}
    local dl_dir=${dl_tgz%%.tar.gz}
    # fmt_info "Download from $dl_url"
    # fmt_info "Retrieve $dl_dir/$bin_name from download url"
    # fmt_info "Deploy bin to $InstallDir/bin"
    curl -sL $dl_url |
            tar -xz -C ./bin --strip-components=1 $dl_dir/$bin_name
}

fd_install() {
    git_repo_install "sharkdp/fd" "fd"
}

ripgrep_install() {
    git_repo_install "BurntSushi/ripgrep" "rg"
}

fzf_install() {
	local fzf_dir="$InstallDir/repo/fzf"
	if [[ ! -e $fzf_dir ]]; then
		# make
		git clone --depth 1 https://github.com/junegunn/fzf.git $fzf_dir
		# --all for set short-cut <ctrl-t> <ctrl-r>
		# make install
		$fzf_dir/install --all --no-update-rc
	fi
}

zlua_install() {
	local zlua_dir="./repo/zlua"
	# make
	if [[ ! -e $zlua_dir ]]; then
		git clone --depth 1 https://gitee.com/mirrors/z.lua.git $zlua_dir
	fi
	# make install
	# add hook to bashrc_tmux
}

Make() {
	fmt_info "Generate bashrc for tmux"
    echo "$bashrc_for_tmux" > $InstallDir/etc/bashrc  # hook in tmux conf

	fmt_info "Generate tmux config"
    tmuxConfig=$(GetTmuxConfig)
	echo "$tmuxConfig" > $scriptDir/etc/tmux.conf

    # check network proxy
    export all_proxy=http://127.0.0.1:10809
    if ! curl -s www.google.com --connect-timeout 3 > /dev/null; then
        fmt_error "Proxy fail. Please check proxy port 10809."
        fmt_error "1. SSH login from wsl ? Exec in wsl: ssh $(whoami)@xx"
        fmt_error "2. SSH remote forward is set ?"
        fmt_error "3. WSL proxy is ok ? Exec in wsl: curl www.google.com"
        fmt_error "4. WIN proxy is ok for 10809 ?"
        fmt_error "5. WIN firewall is opened for wsl? If not, try the following command in powershell."
        fmt_error '   sudo Set-NetFirewallProfile -DisabledInterfaceAliases "vEthernet (WSL)".'
        exit -1
    else
        fmt_info "Proxy ok."
        # fzf. build bin file need github.
        fmt_info "Install fzf"
		fzf_install
        fmt_info "Install zlua"
		zlua_install
		fmt_info "Install fd-find"
		fd_install
		fmt_info "Install ripgrep"
		ripgrep_install
    fi
}

MakeInstall() {
	fmt_info "Deploy file"
	DeployConfigDir  bin  $InstallDir/bin
	DeployConfigDir  etc  $InstallDir/etc

    # set ls color. Beautify the color for ls dir
    echo 'DIR 01;36' > ~/.dir_colors  
    # vim config
    if [ ! -e ~/.vimrc ] || ! grep -q "inoremap jk"  ~/.vimrc ; then
        echo "$vim_config" >> ~/.vimrc
    fi
    # bashrc
    if ! grep -q "# configed" ~/.bashrc ; then
        echo "$bash_config" >> ~/.bashrc
    fi

    # add hook
	# hook tmux
	AddHookToConfigFile    \
		~/.tmux.conf       \
		"source $InstallDir/etc/tmux.conf"
	# hook vim
	AddHookToConfigFile    \
		~/.config/nvim/init.vim       \
		"source $InstallDir/etc/init.vim"
}

main() {
    setup_log_color
	Make
	MakeInstall
}

main

