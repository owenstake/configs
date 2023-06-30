
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

    # lua setting
    export ZLUA_SCRIPT="~/.zplug/repos/skywind3000/z.lua/z.lua"
    # export RANGER_ZLUA=${ZLUA_SCRIPT:-"~/.zplug/repos/skywind3000/z.lua/z.lua"}
    export _ZL_ROOT_MARKERS=".git,.svn,.hg,.root,package.json"    # for `z -b` to return to root dir
    export _ZL_ECHO=1
# }}}
