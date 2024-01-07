
# Basic Terminal settings {{{
    # setopt {{{
        setopt BSD_echo # for fix wired "echo ////" problem
        setopt braceccl # for use "vim {ac}file.c

        # fix history share in mutli panel
        setopt inc_append_history
        setopt share_history
    # }}}
# }}}

# Basic function {{{
    function yp() {
        realpath ${1-.} | xclip
    }

    function xcp() {
        if [ -z $1 ]; then
            realpath $(xclip -o) | xclip
        else
            realpath $1 | xclip
        fi
    }

    function xpa() {
        cp -v $(xclip -o) ${1-.}
    }
# }}}

