
# ohmytmux will source tpm automatically.
if [[ "$SHELL" = *bash ]] && [ -n $TMUX ] ; then
    # function
    rename_tmux_window() {
        local hostname=$1
        local name=${hostname##*-*-}
        if [ -n "$name" ] ; then
            echo "Rename tmux pane '$name'"
            tmux rename-window "${name}"
        else
            echo "Empty name, skip rename tmux pane"
        fi
    }

    ssh() {    # auto rename window with ssh target hostname
        echo "custom ssh"
        local ssh_hostname=$(echo "${@}" | sed -E 's/.*@(\S*).*/\1/')
        local cur_win_name=$(tmux display-message -p '#W')
        # pre login
        # if [ "$TMUX_PANE" == "%0" ] ; then
            rename_tmux_window $ssh_hostname
        # fi
        # ssh
        /bin/ssh "${@}"
        # after logout
        # if [ "$TMUX_PANE" == "%0" ] ; then
            # restore win name
            rename_tmux_window $cur_win_name
        # fi
    }

    # Auto rename in centos server when start tmux
    # if [ "$TMUX_PANE" == "%0" ] ; then
        rename_tmux_window ${HOSTNAME}
    # fi
fi
