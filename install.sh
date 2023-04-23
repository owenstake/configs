#!/bin/bash
set -e   # exit bash script when cmd fail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo "start install ..."

# repo list config to Tsinghua
if [[ ! -e ./oh-my-tuna.py ]]; then
    wget https://tuna.moe/oh-my-tuna/oh-my-tuna.py
    sudo python3 oh-my-tuna.py --global
    sudo apt update
fi

# apps
apps="newsboat ranger zsh global python3-pip universal-ctags vim-gtk \
    xclip net-tools x11-apps"
sudo apt install -y $apps

# python3
python3 -m pip install --upgrade setuptools

if [[ ! -e /usr/bin/node ]]; then
    # nodejs - [How to Install Latest Node.js on Ubuntu – TecAdmin](https://tecadmin.net/install-latest-nodejs-npm-on-ubuntu/ )
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    node --version
    npm  --version
fi

# proxy for github
gateway=$(ip route | head -1 | awk '{print $3}')
export all_proxy=http://$gateway:10809

# oh my zsh - should be first for override .zshrc first
if [[ ! -e ~/.oh-my-zsh ]]; then
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# zplug
if [[ ! -e ~/.zplug ]]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    echo 'source ~/.zplug/init.zsh' >> ~/.zshrc
fi

# fzf
if [[ ! -e ~/.fzf ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> ~/.zshrc
fi

# ripgrep
if [[ ! -e /usr/bin/rg ]]; then
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
    sudo dpkg -i ripgrep_13.0.0_amd64.deb
    rm ripgrep_13.0.0_amd64.deb
fi

# zlua (already install in zplug)

# oh my tmux
if [[ ! -e ~/.tmux ]]; then
    cd
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    cd - 2>/dev/null
fi

if [[ ! -e ~/configs ]]; then
    git clone https://github.com/owenstake/configs.git
    cd configs
    ./bootstrap.sh
    cd -
fi

echo "finish install"

# vim plug. auto trigger install

# wsl config
# wsl --unregister ubt-test
# wsl --import-in-place ubt-test f:\wsl\test\ext4-ubt22-pure.vhdx
