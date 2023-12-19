#!/usr/bin/bash
source lib.sh

scriptDir=$(dirname $0)

if [ -z $scriptDir ]; then
    fmt_error "\$scriptDir is None"
    exit -1
fi
buildDir=$scriptDir/output
InstallDir="$HOME/z/.dotfile"

subdir=(bin etc repo)

mkdir -p $InstallDir
mkdir -p $InstallDir/etc
mkdir -p $InstallDir/repo
mkdir -p $InstallDir/bin


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

git_repo_build() {
    local bin_name=$1
    local repo_name=$2
    local file_pattern=${3:-"x86_64-unknown-linux-musl.*tar.[xg]z$"}
    fmt_info "Download $bin_name"

    local dl_url=$(curl -s https://api.github.com/repos/$repo_name/releases/latest |
                jq -r '.assets[] | select(.name | match("'$file_pattern'"))
                        .browser_download_url'  )
    local dl_file=${dl_url##*/}
    # local dl_dir=${dl_tgz%%.tar.gz}
    # fmt_info "Download from $dl_url"
    # fmt_info "Retrieve $dl_dir/$bin_name from download url"
    # fmt_info "Deploy bin to $InstallDir/bin"
    dst_dir="$buildDir/bin"
    fmt_info "$dl_url"
    # dl_file_ext=${dl_file#*.}
    case $dl_file in
        *.tar.[xg]z)
            # Get final part of filename splitted by "."
            local zipMethod=${dl_file##*.}
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
            # unzip can not read from stdin
            echo " curl -sL $dl_url | unzip - -Wjo "**$bin_name" -d $dst_dir"
            curl -sL $dl_url | unzip - -Wo "**$bin_name" -d $dst_dir -j
            ;;
        *)
            fmt_error "unknow ext decompress for $dl_file"
            ;;
    esac
}

rust_tools_download() {
    git_repo_build "fd"        "sharkdp/fd"
    git_repo_build "rg"        "BurntSushi/ripgrep"
    git_repo_build "zoxide"    "ajeetdsouza/zoxide"
    git_repo_build "lf"        "gokcehan/lf"         "lf-linux-amd64.tar.gz$"
    git_repo_build "eza"       "eza-community/eza"
    git_repo_build "bat"       "sharkdp/bat"

    git_repo_build "bandwhich" "imsnif/bandwhich"
    git_repo_build "btm"       "ClementTsang/bottom"
    git_repo_build "delta"     "dandavison/delta"
    git_repo_build "difft"     "Wilfred/difftastic"  "difft-x86_64-unknown-linux-gnu.tar.gz"
    git_repo_build "dust"      "bootandy/dust"
    git_repo_build "fselect"   "jhspetersson/fselect" "fselect-x86_64-linux-musl.gz$"
    git_repo_build "grex"      "pemistahl/grex"
    git_repo_build "hyperfine" "sharkdp/hyperfine"
    git_repo_build "lsd"       "lsd-rs/lsd"
    git_repo_build "mcfly"     "cantino/mcfly"
    git_repo_build "sd"        "chmln/sd"
    git_repo_build "starship"  "starship/starship"
    git_repo_build "tokei"     "XAMPPRocky/tokei"
    git_repo_build "watchexec" "watchexec/watchexec"

    return
}

fzf_config() {
    local fzf_dir="$InstallDir/repo/fzf"
    action=${1}
    case $action in
        download)
            if [[ ! -e $fzf_dir ]]; then
                # make
                fmt_info "Download fzf through proxy"
                git clone --depth 1 https://github.com/junegunn/fzf.git $fzf_dir
                # --all for set short-cut <ctrl-t> <ctrl-r>
                # make install
            else
                fmt_info "Skip download fzf, $fzf_dir is already exists, "
            fi
            ;;
        install)
            fmt_info "Install fzf through proxy"
            $fzf_dir/install --all --no-update-rc
            # bashrc config already
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
                git clone --depth 1 https://gitee.com/mirrors/z.lua.git $zlua_dir \
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

# ./make all should not polute other dir but itself.
MakeAll() {
    # make -p
    fmt_info "Construct buildDir"
    for d in ${subdir[@]}; do
        fmt_info "make dir $buildDir/$d"
        mkdir -p $buildDir/$d
    done

    fmt_info "Generate bashrc for tmux"
    echo "$bashrc_for_tmux" > $InstallDir/etc/bashrc  # hook in tmux conf

    fmt_info "Generate tmux config"
    local tmuxConfig=$(GetTmuxConfig )
    echo "$tmuxConfig" > $buildDir/etc/tmux.conf

    # check network proxy
    local os_release=$(cat /etc/os-release | grep -xoP 'ID=\K.*')
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
                proxy_server_address=http://$WINIP:10809
                ;;
            *)
                fmt_error "Unknown system type $os_release"
                ;;
        esac
        fmt_info "Env all_proxy set to $proxy_server_address"
        export all_proxy=$proxy_server_address
    fi
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
        zlua_config download
        fzf_config  download
        rust_tools_download
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
    # set ls color. Beautify the color for ls dir
    # echo 'DIR 01;36' > ~/.dir_colors # fix by set terminal color mode to xterm
    # vim config
    if [ ! -e ~/.vimrc ] || ! grep -q "inoremap jk"  ~/.vimrc ; then
        echo "$vim_config" >> ~/.vimrc
        # echo "$vim_config" >> ~/.vimrc
    fi
    # bashrc
    if ! grep -q "# configed" ~/.bashrc ; then
        echo "$bash_config" >> ~/.bashrc
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
    if [ -z "$buildDir" ]; then
        fmt_error "\$buildDir is none"
        return
    fi
    fmt_info "Clean build dir $buildDir"
    rm -r $buildDir
    return
}

MakeUninstall() {
    if [ -z "$InstallDir" ]; then
        fmt_error "\$InstallDir is none!"
        return -1
    fi
    fmt_info "Delete Hook in config file"
    DeleteHookInConfigFile ~/.tmux.conf
    DeleteHookInConfigFile ~/.config/nvim/init.vim

    fmt_info "Clean install dir $InstallDir"
    rm -r $InstallDir
    return
}

main() {
    setup_log_color

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
            MakeAll
            ;;
        *)
            fmt_error "unknown target $1"
            ;;
    esac
}

main "$@"
