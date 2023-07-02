# Aliases ----------------------------------------- {{{

# Basic alias{{{
    alias                                                 \
    ap='apropos'                                          \
    rp='realpath'                                         \
    vi='vim'                                              \
    hi='history'                                          \
    xc='xclip'                                            \
    fd='fdfind'                                           \
    ra='ranger'                                           \
    wt='curl -s "wttr.in/~haizhu+guangzhou?m" | less'     \
    wtq='curl -s "wttr.in/~Quan+Zhou+Fujian?m" | less'    \
    wtx='curl -s "wttr.in/~xiamen+Fujian?m" | less'       \
    lz='lazygit'                                          \
    nb='newsboat -ru $OwenInstallDir/etc/newsboat/rss_links.txt' \
    pg='grep -P'                                          \
    pac="vim ~/.local/etc/pac.txt"                        \
    vic='vim ~/.vimrc'                                    \
    pc='proxychains'                                      \
    psg='ps -ef | grep '                                  \
    py=python
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
