local foundFile=$(search_file "$XDG_CONFIG_HOME" tpm)
if [ $? -eq 0 ] ; then
    export TMUX_TPM="$foundFile"
else
    fmt_error "No found tmux tpm."
fi

# Tmux config in fzf way - now is rarely used {{{
    # https://github.com/junegunn/fzf/wiki/examples#tmux
    # it does not well done, because mask the auto-complete in the dafault shell
    # zsh; needs setopt re_match_pcre. You can, of course, adapt it to your own shell easily.
    function tmk () {
        local sessions
        sessions="$(tmux ls | fzf --exit-0 --multi)"  || return $?
        local i
        for i in "${(f@)sessions}"
        do
            [[ $i =~ '([^:]*):.*' ]] && {
                echo "Killing $match[1]"
                tmux kill-session -t "$match[1]"
            }
        done
    }

    # tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
    # `tm` will allow you to select your tmux session via fzf.
    # `tm irc` will attach to the irc session (if it exists), else it will create it.
    function tm() {
      local change="switch-client"
      [[ -n "$TMUX" ]] || change="attach-session"
      if [ $1 ]; then
        tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
      fi
      session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
    }
# }}}
