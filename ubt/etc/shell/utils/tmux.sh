
# ohmytmux will source tpm automatically.
if [[ "$SHELL" = *bash ]] && [ -n $TMUX ] ; then
    # Auto rename in centos server
    rename_tmux_pane() {
        local hostname=$1
        local name=${hostname##*x86-}
        if [ -n "$name" ] ; then
            echo "Rename tmux pane '$name'"
            tmux rename-window "${name}"
        else
            echo "Empty name, skip rename tmux pane"
        fi
    }
    ssh() {    # auto rename window with ssh target hostname
        echo "custom ssh"
        local hostname=$(echo "${@}" | sed -E 's/.*@(\S*).*/\1/')
        cur_win_name=$(tmux display-message -p '#W')
        # pre login
        if [ "$TMUX_PANE" == "%0" ] ; then
            local name=${hostname##*x86-}
            rename_tmux_pane $name
        fi
        # ssh
        /bin/ssh "${@}"
        # after logout
        if [ "$TMUX_PANE" == "%0" ] ; then
            local name=${cur_win_name}
            rename_tmux_pane $name  # restore win name
        fi
    }
    rename_tmux_pane ${HOSTNAME##*x86-}
fi
