
# app

## fzf
```bash
yum install fd-find ripgrep tmux
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && cd ~/.fzf && ./install
```



# bashrc
```bash
# User specific aliases and functions
alias \
rp='realpath' \
# zc='z -c' \
# zb='z -b' \
# zf='z -I'
# eval "$(lua /home/network/z/z.lua/z.lua --init bash)"
export EDITOR=vim

alias \
ta='tmux a' \
tn='tmux new -s' \
tk='tmux kill-session -t' \
tls='tmux ls' \
tat='tmux a -t' \
tmuxc='vim ~/.tmux.conf' \
tmuxs='tmux source ~/.tmux.conf'

```

# tmux
```bash
# ~/.tmux.conf
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind - split-window -v
bind tab last-window
# set -g window-status-current-bg white   # tmux1.8
set-window-option -g window-status-current-style fg=brightred,bg=colour236,bright # tmux 3.2a
set -g base-index 1
set -g mouse on
# set -g mode-mouse on         # tmux1.8
# set -g mouse-resize-pane on  # tmux1.8
# set -g mouse-select-pane on  # tmux1.8
# set -g mouse-select-window   # tmux1.8on
# set -g mode-mouse on         # tmux1.8
setw -g pane-base-index 1
setw -g mode-keys vi
set-option -g default-command "TMOUT=0 bash"
set-option -g allow-rename off
#setw -g mode-mouse on
#set -g mouse-select-pane on
#set -g mouse-resize-pane on
#set -g mouse-select-window on
```

# vimrc
```bash
inoremap jk <esc>
```
