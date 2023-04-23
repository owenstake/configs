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

fmt_underline() {
  printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

# shellcheck disable=SC2016 # backtick in single-quote
fmt_code() {
  printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_info() {
  printf '%sInfo: %s%s\n' "${FMT_GREEN}${FMT_BOLD}" "$*" "$FMT_RESET"
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

setup_color() {
  # Only use colors if connected to a terminal
    FMT_RAINBOW="
      $(printf '\033[38;2;255;0;0m')
      $(printf '\033[38;2;255;97;0m')
      $(printf '\033[38;2;247;255;0m')
      $(printf '\033[38;2;0;255;30m')
      $(printf '\033[38;2;77;0;255m')
      $(printf '\033[38;2;168;0;255m')
      $(printf '\033[38;2;245;0;172m')
    "

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

# repo list config to Tsinghua
if [[ ! -e ./oh-my-tuna.py ]]; then
    wget https://tuna.moe/oh-my-tuna/oh-my-tuna.py
    sudo python3 oh-my-tuna.py --global -y
    sudo apt update
fi

if ! command_exists zsh; then
    # apps
    apps="newsboat ranger global python3-pip universal-ctags vim-gtk \
        xclip net-tools x11-apps lua5.4 \
        zsh"  # install zsh final for check
    sudo apt install -y $apps
    # python3
    python3 -m pip install --upgrade setuptools
fi


if ! command_exists node ; then
    # nodejs - [How to Install Latest Node.js on Ubuntu – TecAdmin](https://tecadmin.net/install-latest-nodejs-npm-on-ubuntu/ )
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    node --version
    npm  --version
fi

# proxy for github
gateway=$(ip route | head -1 | awk '{print $3}')
export all_proxy=http://$gateway:10809

# check network proxy
if curl -s www.google.com --connect-timeout 3 > /dev/null; then
    fmt_info Proxy ok.
else
    fmt_error Proxy fail. Please check win10 v2ray is ok for 10809.
    return
fi

# zplug
if [[ ! -e ~/.zplug ]]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    echo 'source ~/.zplug/init.zsh' >> ~/.zshrc
fi

# oh my zsh - should be first for override .zshrc first
if [[ ! -e ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended --keep-zshrc
    sudo chsh -s /usr/bin/zsh z
    echo 'export ZSH="$HOME/.oh-my-zsh"' >> ~/.zshrc
    echo 'ZSH_THEME="robbyrussell"'      >> ~/.zshrc
    echo 'source $ZSH/oh-my-zsh.sh'      >> ~/.zshrc
fi

# fzf
if [[ ! -e ~/.fzf ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all  # --all for set short-cut <ctrl-t> <ctrl-r>
    # echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # owen' >> ~/.zshrc
fi

# ripgrep
if ! command_exists rg; then
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

if [[ ! -e ./configs ]]; then
    # shallow clone
    git clone --depth=1 https://github.com/owenstake/configs.git
    cd configs
    ./bootstrap.sh
    cd -
fi

fmt_info "finish install"

# vim plug. auto trigger install

# wsl config
# wsl --unregister ubt-test
# wsl --import-in-place ubt-test f:\wsl\test\ext4-ubt22-pure.vhdx


}

main "$@"


