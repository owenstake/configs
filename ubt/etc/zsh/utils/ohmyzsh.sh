export ZSH_THEME="robbyrussell"
export ZSH=$(find $InstallDir -name ohmyzsh -type d)
source $ZSH/oh-my-zsh.sh
export HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

