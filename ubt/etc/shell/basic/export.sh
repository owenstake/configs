
# Export {{{
    export EDITOR=vim   # For hjkl move
    export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
    [ -d $InstallDir/bin ] && PATH="$PATH:$InstallDir/bin"
    PATH="$PATH:$HOME/.local/bin"
    PATH="$InstallDir/bintop:$PATH"

    if [ -n "$BASH_VERSION" ] ; then
        export CURRENT_SHELL=bash
    else
        if [ -n "$ZSH_VERSION" ] ; then
            export CURRENT_SHELL=zsh
        else
            fmt_error "Unknow current shell."
        fi
    fi

# }}}
