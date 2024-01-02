#!/usr/bin/bash
source lib-cli.sh
source lib-ui.sh
# source lib.sh
set -e   # exit bash script when cmd fail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# TODO: fzf lazygit in

main() {
    # start install
    fmt_info "Start install ..."

    oldDir=$PWD
    buildDir=$(mktemp -d)
    fmt_info "Build dir is $buildDir"
    cd $buildDir

    # Apt repo for Tsinghua
    if ! InOs uos ; then   # Tsinghua repo is not for UOS
        set_apt_source_to_tsinghua
    fi
    # python pip
    set_python_package_source_to_tsinghua

    # get apps installed
    InstallAppsNeed
    fmt_info "Finish install"

    # zinit
    # if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    #     bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    # fi

    # # fzf
    # if [[ ! -e ~/.fzf ]]; then
    #     GitClone https://github.com/junegunn/fzf.git ~/.fzf
    #     ~/.fzf/install --all  # --all for set short-cut <ctrl-t> <ctrl-r>
    #     # echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # owen' >> ~/.zshrc
    # fi

    # zlua (already installed in zplug)
    # if ! command_exists z; then
    #     export RANGER_ZLUA="~/.zplug/repos/skywind3000/z.lua/z.lua"
    # fi

    # vim plug. auto trigger install

    # wsl config
    # wsl --unregister ubt-test
    # wsl --import-in-place ubt-test f:\wsl\test\ext4-ubt22-pure.vhdx
    cd $oldDir
}

time main "$@"

fmt_info "Time elasped is showed above."

