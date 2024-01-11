if export ZSH=$(search_dir $InstallDir "ohmyzsh") ; then
    fmt_info "Load ohmyzsh"
else
    return
fi
export ZSH_THEME="robbyrussell"
export HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
source $ZSH/oh-my-zsh.sh

# key bind
## ref - https://www.zhihu.com/question/49284484
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey ',' autosuggest-accept
bindkey \^U backward-kill-line


