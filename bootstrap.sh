#!/usr/bin/zsh
# cover local config
cp -r etc ~/.local/

# config newsboat. It only worked in thit fuck way.
ln -s ~/.local/etc/newsboat/config ~/.newsboat/config 2>/dev/null

### Force echo to zsh tmux config file
if [[ $1 = "f" ]]
then
    _owen_force_echo=1
    echo "Force echo to zsh tmux config file~~~"
    echo "You must take care of the duplicated term in zsh/tmux config file~~~"
    echo "zsh  $(realpath ~/.zshrc)"
    echo "tmux $(realpath ~/.tmux.conf)"
fi

# WSL config. cp pac to win10. ubt do not need it, because we use proxychain to manual control.
result=$(uname -r | grep -i "microsof" | wc -l)
if [ $result -eq 1 ]
then
    echo "we are in wsl~~~"
    cp ~/.local/etc/pac.txt /mnt/c/MY_SOFTWARE/v2rayN-windows-64/v2rayN-Core-64bit/pac.txt
fi

# -- zsh ----------------------------------------------------------
# To activate the new .zshrc because this exists in father zsh
# unset _owen_zsh_sourced

# enable config file and avoid configed twice
if [ -z ~/.local/etc/zsh.conf ] || [ -n _owen_force_echo ]
then
    echo "# -- owen zsh configing $(realpath ./etc/zsh.conf) ----------">>~/.zshrc
	echo "source ~/.local/etc/zsh.conf">>~/.zshrc
else
    echo "owen zsh configed"
fi


# -- tmux ---------------------------------------------------------
# To activate the new .zshrc because this exists in father zsh
# unset _owen_tmux_sourced

# enable config file and avoid configed twice
# if [[ -z $_owen_zsh_configed ]] {
if [ -z ~/.local/etc/tmux.conf ] || [ -n _owen_force_echo ]
then
    echo "# -- owen tmux configing $(realpath ./etc/tmux.conf) ---------">>~/.tmux.conf
    echo "source ~/.local/etc/tmux.conf">>~/.tmux.conf
else
    echo "owen tmux configed"
fi
