
# Intro {{{
    # Just for my own notes / confirmation and to help anybody else, the ultimate order is .zshenv 鈫? [.zprofile if login] 鈫? [.zshrc if interactive] 鈫? [.zlogin if login] 鈫? [.zlogout sometimes].

    # manual config is needed to confirm and add to ~/.zshrc
    export WinUserName=$(echo $PATH | sed 's#.*/mnt/c/Users/\([^/]*\)/.*#\1#')
    export WinUserHome=/mnt/c/Users/${WinUserName}
    export WinUserDownloads=${WinUserHome}/Downloads
    export WinUserDesktop=${WinUserHome}/Desktop
    export WinUserWeiyun="/mnt/c/Weiyun/Personal"
    export WinUserWeiyunNote="/mnt/c/Weiyun/Personal/my_note"
    export OwenInstallDir="$HOME/.dotfiles"
# }}}


# Export {{{
    export EDITOR=vim   # For hjkl move
    export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
    [ -d $InstallDir/bin ] && PATH="$PATH:$InstallDir/bin"
    PATH="$PATH:$HOME/.local/bin"
# }}}
