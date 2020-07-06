#!/usr/bin/zsh
# get debug flag
_owen_debug=$1
echo -n $1

# cover local config
cp -r etc ~/.local/

# enable config file and avoid source twice
if [[ -z $_owen_inited ]] {
	if [[ -n $_owen_debug ]] {
		echo _owen_inited=$_owen_inited
	}
	echo "source ~/.local/etc/zsh.conf">>~/.zshrc
	echo "source ~/.local/etc/tmux.conf">>~/.tmux.conf
} else {
	if [[ -n $_owen_debug ]] {
		echo "already sourced"
	}
}
