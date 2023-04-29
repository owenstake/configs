#!/usr/bin/zsh
## override config
# override local config    # Make sure the ~/.local exists, otherwise cp will cp dir to ~/.local instead of inside of ~/.local (result in ~/.local/etc)fig
rsync -r etc ~/.local/
sudo rsync -r etc/win10/wsl.conf /etc/wsl.conf     # wsl config, i.e. default user and disk priviledge

# mkdir -p ~/.local/; cp -r etc ~/.local/
# ranger    # Make sure the ~/.config exists, otherwise cp will cp dir to .config instead of inside of ~/.config
rsync -r etc/ranger ~/.config/
# mkdir -p ~/.config/; cp -r etc/ranger ~/.config/
# cp -r etc/ranger ~/.config/

# config newsboat. It only worked in thit fuck way.
# ln -s ~/.local/etc/newsboat/config ~/.newsboat/config 2>/dev/null
# ln -sf ~/.local/etc/newsboat/config ~/.newsboat/config
rsync -r etc/newsboat ~/.config/
# ln -sf $(realpath ./etc/ranger) ~/.config/

ln -sf ~/.local/etc/vim/vim8.vimrc ~/.vimrc

### Force echo to zsh tmux config file
if [[ $1 = "f" ]]
then
    _owen_force_echo=1
    echo "Force echo to zsh tmux config file~~~"
    echo "You must take care of the duplicated term in zsh/tmux config file~~~"
    echo "zsh  $(realpath ~/.zshrc)"
    echo "tmux $(realpath ~/.tmux.conf)"
else
    _owen_force_echo=
fi

# WSL config. cp pac to win10. ubt do not need it, because we use proxychain to manual control.
result=$(uname -r | grep -i "microsof" | wc -l)
if [ $result -eq 1 ]
then
    echo "we are in wsl~~~"
    cp ~/.local/etc/pac.txt /mnt/c/MY_SOFTWARE/v2rayN-windows-64/v2rayN-Core-64bit/pac.txt

    # typora config
    cp ~/.local/etc/typora/owen-auto-number.css /mnt/c/Users/owen/AppData/Roaming/Typora/themes/owen-auto-number.css 
    TYPORA_CSS_REF='@import "owen-auto-number.css";    /* owen config */'
    TYPORA_THEME_FILE="/mnt/c/Users/owen/AppData/Roaming/Typora/themes/github.css"
    sudo sed -i '/owen config/d' $TYPORA_THEME_FILE
    sudo sed -i "1s:^:$TYPORA_CSS_REF\n:" $TYPORA_THEME_FILE

    mkdir -p /mnt/d/.local/
    rsync -r ~/.local/etc/win10/* /mnt/d/.local/win10
fi

try_config() {
    local file=$1
    local msg=$2
    MarkLine="# owen configed" 
    if  ! grep -q "$MarkLine" $file ; then
        echo "owen zsh is configing"
        echo "$MarkLine"                      >> $file
        echo "# -- owen $file config -- "     >> $file
        echo "$msg"                           >> $file
        echo "# -- end owen $file config -- " >> $file
    else
        echo "owen $file is configed already"
    fi
}

# -- zsh ---------------------------------------------------------
try_config ~/.zshrc "source ~/.local/etc/zsh.conf"                                

# -- tmux ---------------------------------------------------------
try_config ~/.tmux.conf "source ~/.local/etc/tmux.conf"                                


