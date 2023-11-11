export OwenInstallDir="$HOME/.dotfiles"  # used in ranger

FMT_RED=$(printf '\033[31m')
FMT_GREEN=$(printf '\033[32m')
FMT_YELLOW=$(printf '\033[33m')
FMT_BLUE=$(printf '\033[34m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

function fmt_info() {
    printf '%sINFO: %s%s\n' "${FMT_GREEN}${FMT_BOLD}" "$*" "$FMT_RESET"
}

function fmt_error() {
    printf '%sERRO: [%s] %s%s\n' "${FMT_RED}${FMT_BOLD}" "$funcstack[2] $@" "$@" "$FMT_RESET"  1>&2
}

setup_color() {
    FMT_RED=$(printf '\033[31m')
    FMT_GREEN=$(printf '\033[32m')
    FMT_YELLOW=$(printf '\033[33m')
    FMT_BLUE=$(printf '\033[34m')
    FMT_BOLD=$(printf '\033[1m')
    FMT_RESET=$(printf '\033[0m')
}


if [[ $(uname -a) == *WSL* ]] ; then
    export OwenInstallDirInWin=${OwenInstallDirInWin:-$(wslpath -ua \
        $(powershell.exe -c '$env:OwenInstallDir' | tr -d '\r'))}
    function ExecPshFile() {
        local filePathInWinForm=$(wslpath -ma $foundFile)
        powershell.exe -File $filePathInWinForm ${@:2:$#}
    }
    function ExecOwenPshFile() {
        SearchAndExecFileWithCallback "ExecPshFile" $OwenInstallDirInWin ${@:2:$#}
        return $?
    }
fi

function SearchAndExecFileWithCallback() {
    local process="${1:-}"
    local dirname=$(realpath $2)
    local fileName=$3

    if [[ -z $dirname ]] ; then
        echo "Env dirname $dirname is null"
        return -1
    fi

    local foundFile=$(find $dirname -name $fileName)
    if [[ 0 == $? ]] ; then
        if [[ -z $foundFile ]] ; then
            echo "No found file $fileName"
        else
            $process $foundFile ${@:4:$#}
            return $?
        fi
    else
        echo "Search failed"
    fi
}

function SearchAndExecFile() {
    SearchAndExecFileWithCallback "" $@
}

function ExecOwenFile() {
    SearchAndExecFileWithCallback "" $OwenInstallDir $@
    return $?
}

