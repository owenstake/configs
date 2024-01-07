
# Export {{{
    export EDITOR=vim   # For hjkl move
    export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
    [ -d $InstallDir/bin ] && PATH="$PATH:$InstallDir/bin"
    PATH="$PATH:$HOME/.local/bin"
# }}}
