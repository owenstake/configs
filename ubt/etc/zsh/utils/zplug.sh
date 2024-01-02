# Zplug manage plug {{{
    ## oh-my-zsh plugins # Supports oh-my-zsh plugins and the like
    ## Config plugin
    # Slow the download speed to avoid blocked by github. Default is 16, it is too many.
    export ZPLUG_THREADS=4
    export ZPLUG_HOME=$(search_dir $InstallDir zplug)
    if [ $? -ne 0 ] ; then
        fmt_error "No found zplug dir."
        return
    fi
    export ZPLUG_REPOS=$ZPLUG_HOME/repos
    if [[ -f $ZPLUG_HOME/init.zsh ]] {
        fmt_info "source zplug"
        source $ZPLUG_HOME/init.zsh
        # oh-my-zsh inner option plugins
        zplug "plugins/colored-man-pages", from:oh-my-zsh, depth:1
        zplug "plugins/cp", from:oh-my-zsh, depth:1
        zplug "plugins/extract", from:oh-my-zsh, depth:1
        zplug "plugins/git", from:oh-my-zsh, depth:1
        zplug "plugins/gitignore", from:oh-my-zsh, depth:1
        zplug "plugins/history-substring-search", from:oh-my-zsh, depth:1
        zplug "plugins/rand-quote", from:oh-my-zsh, depth:1
        zplug "plugins/safe-paste", from:oh-my-zsh, depth:1
        zplug "plugins/sudo", from:oh-my-zsh, depth:1
        zplug "plugins/themes", from:oh-my-zsh, depth:1
        zplug "plugins/zsh_reload", from:oh-my-zsh, depth:1
        # zplug "plugins/z",   from:oh-my-zsh, depth:1
        # zplug "plugins/vi-mode",   from:oh-my-zsh    But I prefer this in emacs way
        # zplug "plugins/zsh-vim-mode",   from:oh-my-zsh, depth:1

        # config plugs
        zplug "changyuheng/zsh-interactive-cd", depth:1
        zplug "denisidoro/navi", depth:1
        zplug "MichaelAquilina/zsh-you-should-use", depth:1
        zplug "supercrabtree/k", depth:1
        zplug "SleepyBag/zsh-confer", depth:1
        zplug "paulirish/git-open", depth:1
        zplug "zsh-users/zsh-syntax-highlighting", depth:1
        zplug "zsh-users/zsh-autosuggestions", depth:1

        # zplug "Powerlevel9k/powerlevel9k", from:github, as:theme, if:"[[ $ZSH_THEME_STYLE == 9k ]]"
        # zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh-theme, from:github, as:theme, if:"[[ $ZSH_THEME_STYLE == spaceship ]]"
        # zplug "caiogondim/bullet-train.zsh", use:bullet-train.zsh-theme, from:github, as:theme, if:"[[ $ZSH_THEME_STYLE == bullet ]]"
        # zplug "skylerlee/zeta-zsh-theme", from:github, as:theme, if:"[[ $ZSH_THEME_STYLE == zeta ]]"

        # Install plugins if there are plugins that have not been installed
        if ! zplug check --verbose; then
          printf "Install? [y/N]: "
          if read -q; then
              echo; zplug install
          fi
        fi
        # Then, source plugins and add commands to $PATH
        zplug load

        ## after plug loaded
        ## zsh-autosuggestions - note the source command must be at the end of .zshrc
        source "$ZPLUG_REPOS/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    } else {
        fmt_info "Please install zplug!"
        # echo "# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh"
        # curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    }
