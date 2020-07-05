#!/usr/bin/zsh
# cover local config
cp -r etc ~/.local/
# enable config file and avoid source twice
if [[ $owen_inited = 1 ]] {
} else {
	echo "source ~/.local/etc/zsh.conf">>~/.zshrc
	echo "source ~/.local/etc/tmux.conf">>~/.tmux.conf
}
