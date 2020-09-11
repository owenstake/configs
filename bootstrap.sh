#!/usr/bin/zsh
# cover local config
cp -r etc ~/.local/

ln -s ~/.local/etc/newsboat/config ~/.newsboat/config 2>/dev/null

# cp pac to win10. ubt do not need it, because we use proxychain to manual control.
result=$(uname -r | grep -i "microsof" | wc -l)
if [ $result -eq 1 ] 
then
    echo "we are in wsl~~~"
    cp ~/.local/etc/pac.txt /mnt/c/MY_SOFTWARE/v2rayN-windows-64/v2rayN-Core-64bit/pac.txt
fi

# -- zsh ----------------------------------------------------------
# To activate the new .zshrc because this exists in father zsh
unset _owen_zsh_sourced

# enable config file and avoid echoed twice
if [[ -z $_owen_zsh_echoed ]] {
  echo "# -- owen zsh config -------------------------">>~/.zshrc
	echo "unset _owen_zsh_sourced">>~/.zshrc    # To activate config bacause of the father config
	echo "source ~/.local/etc/zsh.conf">>~/.zshrc
} else {
  echo "owen zsh echoed"
}

# -- tmux ---------------------------------------------------------
# To activate the new .zshrc because this exists in father zsh
unset _owen_tmux_sourced

# enable config file and avoid echoed twice
if [[ -z $_owen_tmux_echoed ]] {
  echo "# -- owen tmux config -------------------------">>~/.tmux.conf
	echo "unset _owen_tmux_sourced">>~/.tmux.conf     # To activate config bacause of the father config
	echo "source ~/.local/etc/tmux.conf">>~/.tmux.conf
} else {
  echo "owen tmux echoed"
}
