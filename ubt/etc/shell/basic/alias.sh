# Aliases ----------------------------------------- {{{
newsboat_config_file=$(search_config_file "rss_links.txt")
if [ $? -eq 0 ] ; then
    alias nb="newsboat -ru $newsboat_config_file"
fi

if command_exists lsd ; then
    fmt_info "alias ls to lsd"
    alias ls="lsd --icon never"
else
    fmt_error "No found lsd"
fi

if ! command_exists fd  && command_exists fdfind; then
    alias fd=fdfind
fi

if command_exists delta ; then
    alias delta='\delta --line-numbers --side-by-side --hunk-header-style raw'
fi

# Basic alias{{{
    alias                                             \
    ap='apropos'                                      \
    hi='history'                                      \
    lz='lazygit'                                      \
    pg="grep -P"                                      \
    pac="vim ~/.local/etc/pac.txt"                    \
    pc='proxychains'                                  \
    psg='ps -ef | grep '                              \
    py=python                                         \
    ra='ranger'                                       \
    rp='realpath'                                     \
    vi='vim'                                          \
    vic="vim ~/.vimrc"                                \
    wt='curl -s "wttr.in/~haizhu+guangzhou?m" | less' \
    wtq='curl -s "wttr.in/~QuanGang+Fujian?m" | less' \
    wtx='curl -s "wttr.in/~xiamen+Fujian?m" | less'   \
    xc='xclip'                                        \
    sudo='\sudo -E env "PATH=$PATH"'
# }}}

# zlua {{{
    # <ctrl-t><ctrl-t> for zf in fzf
    # already define in z.lua
    # zz='z -i'  \
    # zf='z -I'  \
    # zb='z -b'  \
    # zbi='z -b -i'  \
    # zbf='z -b -I'  \
    # zh='z -I -t .'  \
    # zzc='zz -c' \
    alias                          \
    zi='z -i'                      \
    zl='z -l'                      \
    zc='z -c'                      \
    zcl='z -c -l'                  \
    zcf='z -c -I'                  \
    zch='z -c -I -t .'             \
    zd="cd $WinUserHome/Downloads" \
    zr="cd $WinUserHome/Desktop"   \
    zp="cd $WinUserWeiyun"         \
    zn="cd $WinUserWeiyun/my_note" \
# }}}

# tar .tgz alias {{{
    alias tarc='tar -czvf'
    alias tarl='tar -tf'
    alias tarx='tar -xzvf'
# }}}

# LukeSmith - Verbosity and settings that you pretty much just always are going to want.{{{
    alias \
    cp='cp -iv' \
    df='df -h' \
    rm='rm -vI' \
    mkd="mkdir -pv" \
# }}}

# Git Alias - ref - liaoxuefeng {{{
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.ci commit
    git config --global alias.br branch
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global color.ui true
    alias gla='git log --oneline --decorate --all --graph'
# }}}

# Zsh config{{{
    alias zshc="vim ~/.zshrc"
    alias zshs="source ~/.zshrc"
# }}}

# Tmux alias {{{
    alias \
    ta='tmux a' \
    tn='tmux new -s' \
    tk='tmux kill-session -t' \
    tls='tmux ls' \
    tat='tmux a -t' \
    tmuxc='vim ~/.tmux.conf' \
    tmuxs='tmux source ~/.tmux.conf' \
# }}}
