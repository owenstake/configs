#### glocal var #####################
curOsName=$(GetCurOsName)
appsCommonStr="
    cargo fd-find global python3-pip universal-ctags vim-gtk
    ranger newsboat openssh-server tree trash-cli wmctrl
    x11-apps xclip xbindkeys xautomation xvkbd zsh
    "

case $curOsName in
    uos)
        appsExpected="$appsCommonStr"
        ;;
    ubuntu)
        appsExpected="$appsCommonStr clangd bat wl-clipboard "
        ;;
esac

#### function ######################
InstallV2rayA() {
    if ! command_exists v2raya; then
        wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc
        echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list

        sudo apt update
        sudo apt install v2raya v2ray ## 也可以使用 xray 包
        sudo systemctl start v2raya.service
        sudo systemctl enable v2raya.service
    fi
}

InstallWudaoDict() {
    # wudao - [ChestnutHeng/Wudao-dict: 有道词典的命令行版本，支持英汉互查和在线查询。](https://github.com/ChestnutHeng/Wudao-dict )
    local repo_dir=$1
    if ! command_exists wd; then
        (
        python3 -m pip install bs4 lxml   # for wudao-dict
        mkdir -p $InstallDir/lib && cd $_
        GitClone https://github.com/chestnutheng/wudao-dict $repo_dir
        cd $repo_dir/wudao-dict
        sudo bash setup.sh #或者sudo ./setup.sh
        )
    fi
}

InstallGolang() {
    # golang 1.21.4
    if ! command_exists go; then
        local cpu_arch=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
        local golang_url="https://go.dev/dl/go1.21.4.linux-${cpu_arch}.tar.gz"
        wget $golang_url
        mkdir -p ~/.local
        tar -C ~/.local -xzf "go1.21.4.linux-${cpu_arch}.tar.gz"
        rm $_
        line="PATH=\$PATH:\$HOME/.local/go/bin"
        if ! grep -q "$line" ~/.profile ; then
            echo "$line" >> ~/.profile
            source ~/.profile
        fi
        go env -w GOPROXY=https://goproxy.cn,direct
    fi
}

ohmyzsh_config() {
    local action=${1}
    local repo_dir=$2
    case $action in
        download)
            fmt_info "Download ohmyzsh"
            if [ ! -e $repo_dir ]; then
                GitClone https://github.com/ohmyzsh/ohmyzsh.git $repo_dir
            fi
            ;;
        install)
            fmt_info "Install ohmyzsh"
            # bashrc config already
            ;;
        *)
            fmt_error "unknown action $action"
            ;;
    esac
    return
}

zplug_config() {
    local action=${1}
    local repo_dir=$2
    case $action in
        download)
            fmt_info "Download zplug"
            if [ ! -e $repo_dir ]; then
                GitClone https://github.com/zplug/zplug.git $repo_dir
            fi
            ;;
        install)
            fmt_info "Install zplug but do nothing"
            # bashrc config already
            ;;
        *)
            fmt_error "unknown action $action"
            ;;
    esac
    return
}


# InstallZplug() {
#     # zplug
#     if [[ ! -e ~/.zplug ]]; then
#         curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
#         echo 'source ~/.zplug/init.zsh' >> ~/.zshrc
#     fi
# }

ohmytmux_config() {
    # local repo_dir=$1
    # if [ ! -e "$repo_dir" ]; then
    #     # cd ~
    #     # GitClone https://github.com/gpakosz/.tmux.git
    #     # ln -s -f .tmux/.tmux.conf
    #     # cp .tmux/.tmux.conf.local .
    #     # cd - 2>/dev/null
    # fi
    local action=${1}
    local repo_dir=$2
    case $action in
        download)
            fmt_info "Download ohmytmux"
            if [[ ! -e $repo_dir ]]; then
                GitClone https://github.com/gpakosz/.tmux.git $repo_dir
            fi
            ;;
        install)
            fmt_info "Install ohmytmux"
            mkdir -p "$XDG_CONFIG_HOME/tmux"
            ln -sf "$repo_dir/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
            cp "$repo_dir/.tmux.conf.local" "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
            # bashrc config already
            ;;
        *)
            fmt_error "unknown action $action"
            ;;
    esac
    return
}

InstallTmuxTPM() {
    local repo_dir=$1
    if [ ! -e "$repo_dir" ]; then
        GitClone https://github.com/tmux-plugins/tpm  \
                            $XDG_CONFIG_HOME/tmux/plugins/tpm
    fi
}

InstallNodejs() {
    # Nodejs install
    if ! command_exists node ; then
        NODE_MAJOR=20
        # CUR_NODE_MAJOR=$(node --version | cut -d'.' -f1 | tr -d 'v')
        # if [ "$CUR_NODE_MAJOR" -lt "$NODE_MAJOR" ] ; then
            fmt_info "Install nodejs $NODE_MAJOR"
            sudo apt install -y ca-certificates curl gnupg
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
                | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
            echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg]"\
                    "https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | \
                    sudo tee /etc/apt/sources.list.d/nodesource.list
            sudo apt install nodejs -y
        # fi
    fi
}

InstallAppsNeed() {
    appsInstalledStr=$(apt list --installed 2>/dev/null | cut -d'/' -f1)
    declare -A appsInstalled
    for a in $appsInstalledStr; do
        appsInstalled[$a]=1   # mark as installed
    done

    # get apps need install
    # check app expected
    # declare -A appsNeedInstall
    for a in $appsExpected; do
        if [ ! -v "appsInstalled[$a]" ] ; then # check if app is already installed
            appsNeedInstall+=($a)
        fi
    done

    if [ 0 -eq ${#appsNeedInstall[@]} ]; then
        fmt_info "Expected apps is all installed."
    else
        fmt_info "Install ${#appsNeedInstall[@]} apps ${appsNeedInstall[@]}"
        sudo apt install -y ${appsNeedInstall[@]}
    fi
}

set_python_package_source_to_tsinghua() {
    # python pip mirror config
    if [[ ! -e ~/.pip/pip.conf ]]; then
        mkdir -p ~/.pip
        echo "[global]                                            " >> ~/.pip/pip.conf
        echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
        echo "[install]                                           " >> ~/.pip/pip.conf
        echo "trusted-host=pypi.tuna.tsinghua.edu.cn              " >> ~/.pip/pip.conf
        # python3 - upgrade pip
        python3 -m pip install --upgrade setuptools
        python3 -m pip install asciinema
        python3 -m pip install sshconf
    fi
}

set_apt_source_to_tsinghua() {
    if ! grep -q tsinghua /etc/apt/sources.list /etc/apt/sources.list.d/* ; then
        wget https://tuna.moe/oh-my-tuna/oh-my-tuna.py
        sudo python3 oh-my-tuna.py --global -y
        sudo apt update
    fi
}

test_connectivity_to_google() {
    if curl -s www.google.com --connect-timeout 3 > /dev/null; then
        fmt_info "Proxy ok."
    else
        fmt_error "Proxy fail. Please check v2rayA or v2rayN(win10-wsl) is ok for 10809."
        fmt_error "1. win v2rayN is ok for 10809 ?"
        fmt_error "2. win v2rayN is ok for remote ?"
        fmt_error "3. win firewall is opened for wsl ?. If not, do the following command in powershell."
        fmt_error 'sudo Set-NetFirewallProfile -DisabledInterfaceAliases "vEthernet (WSL)".'
        return
    fi
}

if [[ $(uname -a) == *WSL* ]] ; then
    export OwenInstallDirInWin=${OwenInstallDirInWin:-$(wslpath -ua \
                    $(powershell.exe -c '$env:OwenInstallDir' | tr -d '\r'))}
    function ExecPshFile() {
        local filePathInWinForm=$(wslpath -ma $foundFile)
        powershell.exe -File $filePathInWinForm ${@:2:$#}
    }
    function ExecOwenPshFile() {
        SearchAndExecFileWithCallback "ExecPshFile" $OwenInstallDirInWin ${@:2:$#}
        return $?
    }
fi

generate_ssh_config_file() {
    dst=$1
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
                $dst
		fi
	fi
}

