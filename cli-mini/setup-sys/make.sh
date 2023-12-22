#!/usr/bin/bash
source lib.sh

scriptDir=$(dirname $0)

if [ -z $scriptDir ]; then
    fmt_error "\$scriptDir is None"
    exit -1
fi
# global var
subdir=(bin etc repo)
buildDir=$scriptDir/output
mkdir $buildDir

InstallDir="$HOME/z/.dotfile"
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
    # export PATH=\$PATH:\$HOME/.cargo/bin
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

try_get_download_url() {
    local type=$1
    local release_info=$2
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
            return -1
    esac
    local file_pattern="${basename_pattern}.${ext_pattern}$"
    local dl_url=$(echo "$release_info" | jq -r '.assets[] | select(.name |
                        match("'$file_pattern'")).browser_download_url'  )
    if [ $? -ne 0 ] || [ -z "$dl_url" ]; then
        fmt_error "Get dl_url fail, file_pattern match nothing"
        return -1
    else
        echo "$dl_url"  # output
    fi
    return
}

base_binstall() {
    local language=$1
    local bin_name=$2
    local repo_name=$3
    fmt_info "Download $bin_name in $file_pattern from $repo_name"
    local GITHUB_API_REMAIN_COUNTS=$(curl -sf https://api.github.com/rate_limit \
                                                | jq '.rate.remaining')
    if [ $GITHUB_API_REMAIN_COUNTS -lt 30 ]; then
        fmt_info "Github API count has be exhausted, use github token."
        if [ -z $GITHUB_TOKEN ]; then
            fmt_error "Please set GITHUB_TOKEN into env"
            return -1
        else
            local CURL_OPTION="--header \"Authorization: Bearer $GITHUB_TOKEN\""
        fi
    fi
    local release_info=$(curl -sf $CURL_OPTION https://api.github.com/repos/$repo_name/releases/latest)
    if [ $? -ne 0 ] ; then
        fmt_error "Curl github api fail"
        return -1
    fi
    # if [ -z "$release_info" ] ; then
    #     fmt_error "curl github api ok, but release_info is null"
    #     return -1
    # fi
    # if echo "$release_info" | grep "API rate limit" ; then
    #     fmt_error "github API rate limit!\n$release_info"
    #     return -1
    # fi
    fmt_error "$release_info" 2>&1 | head -n5
    local dl_url=$(try_get_download_url "$language" "$release_info" "$file_pattern")
    if [ $? -ne 0 ] ; then
        fmt_error "dl_url get fail $dl_url "
        return -1
    fi

    local dl_file=${dl_url##*/}
    # local dl_dir=${dl_tgz%%.tar.gz}
    # fmt_info "Download from $dl_url"
    # fmt_info "Retrieve $dl_dir/$bin_name from download url"
    # fmt_info "Deploy bin to $InstallDir/bin"
    local dst_dir="$buildDir/bin"
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
            # unzip can not read from stdin
            # echo " curl -sL $dl_url | unzip - -Wjo "**$bin_name" -d $dst_dir"
            # curl -sL $dl_url | unzip - -Wo "**$bin_name" -d $dst_dir -j
            echo "zip url dl_url"
            tmpfile="/tmp/temp.zip"
            curl -L $dl_url -o $tmpfile && 
                    unzip -j $tmpfile "**/$bin_name" -d $dst_dir &&
                    rm $tmpfile
            ;;
        *)
            fmt_error "unknow ext decompress for $dl_file"
            ;;
    esac
}

cargo_binstall() {
    base_binstall "rust" "${@}"
    return $?
}

golang_binstall() {
    base_binstall "golang" "${@}"
    return $?
}

golang_tools_install_by_direct_download() {
    golang_binstall "lf"              "gokcehan/lf"
    golang_binstall "cloudpan189-go"  "tickstep/cloudpan189-go"
}

rust_tools_install_by_cargo_binstall() {
    cargo_binstall "cargo-binstall"  "cargo-bins/cargo-binstall"
    local cpu_arch=$(uname -m)
    $buildDir/bin/cargo-binstall -y --no-discover-github-token  \
                    --disable-strategies compile                \
                    --targets "${cpu_arch}-unknown-linux-musl"  \
                    --targets "${cpu_arch}-unknown-linux-gnu"   \
                    --install-path $buildDir/bin                \
                    bat fd-find ripgrep zoxide eza              \
                    bandwhich bottom difftastic du-dust fselect \
                    hyperfine lsd mcfly sd starship             \
                    tokei watchexec-cli
    return
}

# this func only for x86, unable to compat for multi os
rust_tools_install_by_direct_download() {
    # cargo_binstall "cargo-binstall"  "cargo-bins/cargo-binstall"

    # $buildDir/bin/cargo-binstall -y --install-path \
    #                 $buildDir/bin fd rg zoxide eza \
    #                 bat bandwhich btm delta difftastic dust fselect \
    #                 grex hyperfine lsd mcfly sd starship tokei watchexec

    # rust install for compile
    # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    # lf is golang tool
    # delta do no support cargo-binstall
    # grex is not support in aarch64

    # golang - direct download
    cargo_binstall "lf"        "gokcehan/lf"         "lf-linux-amd64.tar.gz$"

    # rust - direct download
    cargo_binstall "delta"     "dandavison/delta"
    cargo_binstall "difft"     "Wilfred/difftastic"  "difft-x86_64-unknown-linux-gnu.tar.gz"
    cargo_binstall "grex"      "pemistahl/grex"

    # rust - cargo-binstall
    cargo_binstall "fd"        "sharkdp/fd"
    cargo_binstall "rg"        "BurntSushi/ripgrep"
    cargo_binstall "eza"       "eza-community/eza"
    cargo_binstall "bat"       "sharkdp/bat"
    cargo_binstall "watchexec" "watchexec/watchexec"
    cargo_binstall "zoxide"    "ajeetdsouza/zoxide"

    cargo_binstall "bandwhich" "imsnif/bandwhich"
    cargo_binstall "btm"       "ClementTsang/bottom"
    cargo_binstall "dust"      "bootandy/dust"
    cargo_binstall "fselect"   "jhspetersson/fselect" "fselect-x86_64-linux-musl.gz$"
    cargo_binstall "hyperfine" "sharkdp/hyperfine"

    cargo_binstall "lsd"       "lsd-rs/lsd"
    cargo_binstall "mcfly"     "cantino/mcfly"
    cargo_binstall "sd"        "chmln/sd"
    cargo_binstall "starship"  "starship/starship"
    cargo_binstall "tokei"     "XAMPPRocky/tokei"


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
    for d in "${subdir[@]}"; do
        fmt_info "make dir $buildDir/$d"
        mkdir -p $buildDir/$d
    done

    fmt_info "Generate bashrc for tmux"
    echo "$bashrc_for_tmux" > $InstallDir/etc/bashrc  # hook in tmux conf

    fmt_info "Generate tmux config"
    local tmuxConfig=$(GetTmuxConfig )
    echo "$tmuxConfig" > $buildDir/etc/tmux.conf

    # check network proxy
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
                proxy_server_address=http://$WINIP:10809
                ;;
            *)
                fmt_error "Unknown system type $os_release"
                return -1
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
        golang_tools_install_by_direct_download
        rust_tools_install_by_cargo_binstall
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
