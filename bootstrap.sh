#!/usr/bin/zsh
## override config
# override local config    # Make sure the ~/.local exists, otherwise cp will cp dir to ~/.local instead of inside of ~/.local (result in ~/.local/etc)fig
rsync -r etc ~/.local/
rsync -r bin ~/.local/
rsync -r etc/win10/wsl.conf /etc/wsl.conf     # wsl config, i.e. default user and disk priviledge

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
    sed -i '/owen config/d' $TYPORA_THEME_FILE
    sed -i "1s:^:$TYPORA_CSS_REF\n:" $TYPORA_THEME_FILE

    mkdir -p /mnt/d/.local/
    rsync -r ~/.local/etc/win10/* /mnt/d/.local/win10
fi

# -- zsh ----------------------------------------------------------
# To activate the new .zshrc because this exists in father zsh
# unset _owen_zsh_sourced

# enable config file and avoid configed twice
if [ -e ~/.local/etc/zsh.conf ] && [ -z $_owen_force_echo ]
then
    echo "owen zsh configed"
else
    echo "# -- owen zsh configing $(realpath ./etc/zsh.conf) -----">>~/.zshrc
    echo "source ~/.local/etc/zsh.conf">>~/.zshrc
fi


# -- tmux ---------------------------------------------------------
# To activate the new .zshrc because this exists in father zsh
# unset _owen_tmux_sourced

# enable config file and avoid configed twice
# if [[ -z $_owen_zsh_configed ]] {
if [ -e ~/.local/etc/tmux.conf ] && [ -z $_owen_force_echo ]
then
    echo "owen tmux configed"
else
    echo "# -- owen tmux configing $(realpath ./etc/tmux.conf) ---">>~/.tmux.conf
    echo "source ~/.local/etc/tmux.conf">>~/.tmux.conf
fi
