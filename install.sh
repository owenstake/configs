#!/bin/bash
set -e   # exit bash script when cmd fail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# function
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

fmt_info() {
    printf '%sINFO: %s%s\n' "${FMT_GREEN}${FMT_BOLD}" "$*" "$FMT_RESET"
}

fmt_error() {
    printf '%sERRO: %s%s\n' "${FMT_RED}${FMT_BOLD}" "$*" "$FMT_RESET"
}

git_clone() {
    # local url=$1
    git clone --depth 1 $@
}

setup_color() {
    FMT_RED=$(printf '\033[31m')
    FMT_GREEN=$(printf '\033[32m')
    FMT_YELLOW=$(printf '\033[33m')
    FMT_BLUE=$(printf '\033[34m')
    FMT_BOLD=$(printf '\033[1m')
    FMT_RESET=$(printf '\033[0m')
}

main() {
    setup_color
    # start install
    fmt_info "start install ..."

    oldDir=$PWD
    buildDir=$(mktemp -d)
    fmt_info "Build dir is $buildDir"
    cd $buildDir

    if ! command_exists zsh; then
        # repo list config to Tsinghua
        wget https://tuna.moe/oh-my-tuna/oh-my-tuna.py
        sudo python3 oh-my-tuna.py --global -y
        sudo apt update
        sudo apt upgrade -y
        # apps. rank.
        apps1="newsboat ranger global python3-pip universal-ctags vim-gtk \
            xclip net-tools x11-apps lua5.4 subversion fd-find wl-clipboard \
            openssh-server tree bat "
        apps2=" poppler-utils "
        sudo apt install -y $apps1
        sudo apt install -y $apps2
        sudo apt install -y zsh   # install zsh final for check
        sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
        # start service
        sudo systemctl enable ssh
    fi

    # python config
    if [[ ! -e ~/.pip/pip.conf ]]; then
        mkdir -p ~/.pip
        echo "[global]                                            " >> ~/.pip/pip.conf
        echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
        echo "[install]                                           " >> ~/.pip/pip.conf
        echo "trusted-host=pypi.tuna.tsinghua.edu.cn              " >> ~/.pip/pip.conf
        # python3 - upgrade pip
        python3 -m pip install --upgrade setuptools
        python3 -m pip install asciinema
    fi

    # Proxy for github
    gateway=$(ip route | head -1 | awk '{print $3}')
    export all_proxy=http://$gateway:10809

    if ! command_exists node ; then
        # nodejs 18 install - [How to Install Latest Node.js on Ubuntu – TecAdmin](https://tecadmin.net/install-latest-nodejs-npm-on-ubuntu/ )
        curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt install -y nodejs
        # npm config
        sudo npm config set registry https://registry.npm.taobao.org  # mirror list
        sudo npm config set update-notifier false  # avoid update notice
        sudo npm config set fund false             # avoid fund notice
        # sudo npm config ls -l  # show all node config key=value
        node --version
        npm  --version
    fi

    # check network proxy
    if curl -s www.google.com --connect-timeout 3 > /dev/null; then
        fmt_info Proxy ok.
    else
        fmt_error Proxy fail. Please check win10 v2ray is ok for 10809.
        return
    fi

    # oh my zsh - should be first for override .zshrc first
    if [[ ! -e ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh )" \
            "" --unattended --keep-zshrc
        sudo chsh -s /usr/bin/zsh z
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
        git_clone https://github.com/junegunn/fzf.git ~/.fzf
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
        git_clone https://github.com/gpakosz/.tmux.git
        ln -s -f .tmux/.tmux.conf
        cp .tmux/.tmux.conf.local .
        cd - 2>/dev/null
    fi

    if [[ ! -e ~/configs ]]; then
        (
        cd ~
        # shallow clone
        git_clone https://github.com/owenstake/configs.git
        cd configs
        ./bootstrap.sh
        )
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
        mkdir -p ~/.local/lib && cd $_
        git_clone https://github.com/chestnutheng/wudao-dict
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

    fmt_info "finish install"

    # vim plug. auto trigger install

    # wsl config
    # wsl --unregister ubt-test
    # wsl --import-in-place ubt-test f:\wsl\test\ext4-ubt22-pure.vhdx
    cd $oldDir
}

time main "$@"

fmt_info "time elasped is showed above ^"

