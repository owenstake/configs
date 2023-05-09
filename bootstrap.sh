#!/usr/bin/zsh
#
export WinUserName=$(echo $PATH | sed 's$.*/mnt/c/Users/\([^/]*\)/AppData.*$\1$g')

function try_config() {
    local file=$1
    local msg=$2
    MarkLine="# owen configed" 
    if ! grep -q "$MarkLine" $file ; then
        echo "owen $file is configing"
        echo "$MarkLine"                      >> $file
        echo "# -- owen $file config -- "     >> $file
        echo "$msg"                           >> $file
        echo "# -- end owen $file config -- " >> $file
    else
        echo "owen $file is configed already"
    fi
}

function main() {
    ## override config
    mkdir -p ~/.local $$ mkdir -p ~/.config
    rsync -r etc          ~/.local/
    rsync -r etc/ranger   ~/.config/
    rsync -r etc/newsboat ~/.config/
    rsync -r etc/fzf ~/.config/fzf
    ln -sf ~/.local/etc/vim/vim8.vimrc ~/.vimrc

    ### Force echo to zsh tmux config file
    if [[ $1 = "f" ]]; then
        _owen_force_update=1
        echo "Force update config files including zsh,tmux"
        echo "You must take care of the duplicated term in zsh/tmux config file~~~"
        echo "zsh  $(realpath ~/.zshrc)"
        echo "tmux $(realpath ~/.tmux.conf)"
    else
        _owen_force_update=
    fi

    # WSL config. cp pac to win10. ubt do not need it, because we use proxychain to manual control.
    if uname -r | grep -qi "microsof"; then
        echo "we are in wsl~~~"
        # wsl system configs
        sudo rsync -r etc/win10/wsl.conf /etc/wsl.conf     # wsl config, i.e. default user and disk priviledge
        # v2ray
        cp ~/.local/etc/pac.txt /mnt/c/MY_SOFTWARE/v2rayN-windows-64/v2rayN-Core-64bit/pac.txt

        # typora config
        cp ~/.local/etc/typora/owen-auto-number.css /mnt/c/Users/$WinUserName/AppData/Roaming/Typora/themes/owen-auto-number.css 
        TYPORA_CSS_REF='@import "owen-auto-number.css";    /* owen config */'
        TYPORA_THEME_FILE="/mnt/c/Users/$WinUserName/AppData/Roaming/Typora/themes/github.css"
        sudo sed -i '/owen config/d' $TYPORA_THEME_FILE
        sudo sed -i "1s:^:$TYPORA_CSS_REF\n:" $TYPORA_THEME_FILE

        # cp to 
        mkdir -p /mnt/d/.local/ && rsync -r etc/win10/* /mnt/d/.local/win10
    fi

    # -- zsh config ---------------------------------------------------------
    try_config ~/.zshrc "source ~/.local/etc/zsh.conf"

    # -- tmux config ---------------------------------------------------------
    try_config ~/.tmux.conf "source ~/.local/etc/tmux.conf"
}

main $@


