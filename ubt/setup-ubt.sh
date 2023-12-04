#!/usr/bin/bash
source lib.sh
set -e   # exit bash script when cmd fail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# glocal var
curOsName=$(GetCurOsName)
appsCommonStr="
    fd-find global python3-pip universal-ctags vim-gtk
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

main() {
    setup_color
    # start install
    fmt_info "Start install ..."

    oldDir=$PWD
    buildDir=$(mktemp -d)
    fmt_info "Build dir is $buildDir"
    cd $buildDir

    # if ! command_exists trash; then
        # APT repo for Tsinghua
        if ! InOs uos ; then   # Tsinghua repo is not for UOS
            if ! grep -q tsinghua /etc/apt/sources.list /etc/apt/sources.list.d/* ; then
                wget https://tuna.moe/oh-my-tuna/oh-my-tuna.py
                sudo python3 oh-my-tuna.py --global -y
                sudo apt update
            fi
        fi

        # Nodejs install
        if ! command_exists node ; then
            NODE_MAJOR=20
            CUR_NODE_MAJOR=$(node --version | cut -d'.' -f1 | tr -d 'v')
            if [ $CUR_NODE_MAJOR -lt $NODE_MAJOR ] ; then
                fmt_info "Install nodejs $NODE_MAJOR"
                sudo apt install -y ca-certificates curl gnupg
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
                    | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
                echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg]"\
                        "https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | \
                        sudo tee /etc/apt/sources.list.d/nodesource.list
                sudo apt install nodejs -y
            fi
        fi
        # sudo apt upgrade -y --allow-unauthenticated

        # get apps installed
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

        # bat
        if [ -f /usr/bin/batcat ] && \
            [ ! -f /usr/bin/bat ] && \
            [ ! -e /usr/local/bin/bat ] ; then
            sudo ln -s /usr/bin/batcat /usr/local/bin/bat
        fi
        # start service
        # sudo systemctl enable ssh
    # fi

    # install v2rayA
    if ! command_exists v2raya; then
        wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc
        echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list

        sudo apt update
        sudo apt install v2raya v2ray ## 也可以使用 xray 包
        sudo systemctl start v2raya.service
        sudo systemctl enable v2raya.service
    fi

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

    # Proxy
    if InWsl ; then
        gateway=$(ip route | head -1 | awk '{print $3}')
        export all_proxy=http://$gateway:10809
    else
        export all_proxy=http://127.0.0.1:20171  # v2rayA
    fi

    # check network proxy
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

    # oh my zsh - should be first for override .zshrc first
    if [[ ! -e ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh )" \
            "" --unattended --keep-zshrc
        sudo chsh -s /usr/bin/zsh $(whoami)
        echo 'export ZSH="$HOME/.oh-my-zsh"' >> ~/.zshrc
        echo 'ZSH_THEME="robbyrussell"'      >> ~/.zshrc
        echo 'source $ZSH/oh-my-zsh.sh'      >> ~/.zshrc
    fi

    # zplug
    if [[ ! -e ~/.zplug ]]; then
        curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
        # echo 'export ZPLUG_THREADS=16' >> ~/.zshrc
        echo 'source ~/.zplug/init.zsh' >> ~/.zshrc
    fi

    # zinit
    # if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    #     bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    # fi

    # fzf
    if [[ ! -e ~/.fzf ]]; then
        GitClone https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all  # --all for set short-cut <ctrl-t> <ctrl-r>
        # echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # owen' >> ~/.zshrc
    fi

    # ripgrep
    if ! command_exists rg; then
        curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
        sudo dpkg -i ripgrep_13.0.0_amd64.deb
        # rm ripgrep_13.0.0_amd64.deb
    fi

    # zlua (already installed in zplug)
    # if ! command_exists z; then
    #     export RANGER_ZLUA="~/.zplug/repos/skywind3000/z.lua/z.lua"
    # fi

    # oh my tmux
    if [[ ! -e ~/.tmux ]]; then
        cd ~
        GitClone https://github.com/gpakosz/.tmux.git
        ln -s -f .tmux/.tmux.conf
        cp .tmux/.tmux.conf.local .
        cd - 2>/dev/null
    fi

    # tldr
    if ! command_exists tldr; then
        fmt_info "tldr install and config"
        sudo npm install -g tldr
        tldr --update
    fi

    # wudao - [ChestnutHeng/Wudao-dict: 有道词典的命令行版本，支持英汉互查和在线查询。](https://github.com/ChestnutHeng/Wudao-dict )
    if ! command_exists wd; then
        (
        python3 -m pip install bs4 lxml   # for wudao-dict
        mkdir -p $OwenInstallDir/lib && cd $_
        GitClone https://github.com/chestnutheng/wudao-dict
        cd ./wudao-dict/wudao-dict
        sudo bash setup.sh #或者sudo ./setup.sh
        )
    fi

    # lazygit
    if ! command_exists lazygit; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        # rm lazygit lazygit.tar.gz # clean
    fi

    # golang 1.21.4
    if ! command_exists go; then
        wget https://go.dev/dl/go1.21.4.linux-arm64.tar.gz
        mkdir -p ~/.local
        tar -C ~/.local -xzf go1.21.4.linux-arm64.tar.gz
        rm $_
        line="PATH=\$PATH:\$HOME/.local/go/bin"
        if ! grep -q "$line" ~/.profile ; then
            echo "$line" >> ~/.profile
            source ~/.profile
        fi
        go env -w GOPROXY=https://goproxy.cn,direct
    fi

    fmt_info "Finish install"

    # vim plug. auto trigger install

    # wsl config
    # wsl --unregister ubt-test
    # wsl --import-in-place ubt-test f:\wsl\test\ext4-ubt22-pure.vhdx
    cd $oldDir
}

time main "$@"

fmt_info "Time elasped is showed above."

