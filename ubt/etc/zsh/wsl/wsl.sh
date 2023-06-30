# WSL config {{{
# Fix xclip, so we can copy between win10 and linux.
# Xclip depends on x11 on linux and Xserver on win10.
# To make xclip works on vim, we also need install vim-gtk
if uname -r | grep -qi "microsof" ; then
    fmt_info "We are in wsl~~~"

    zshroot=$(dirname $0)
    source $zshroot/lib/func.sh
    source $zshroot/lib/export.sh
    source $zshroot/lib/alias.sh
    # Xserver connection check. It costs 1s.
    CheckXserver
    ExecOwenFile "sshconfig.py"

    # Network - init when WSL starting {{{
    local linux_wsl_started_flag=/tmp/.wsl_linux_started
    if [ ! -f $linux_wsl_started_flag ]; then 
        fmt_info "$WSL_DISTRO_NAME WSL is starting~~~"
        fmt_info "Configing"
        powershell.exe -File $PshDir'init-wsl.ps1' \
            $WSL_DISTRO_NAME  $WSLIP  $WINIP  $PshDir
        # /tmp is tmpfs. Everytime linux system restart, /tmp will be flush
        touch $linux_wsl_started_flag    
    else
        fmt_info "$WSL_DISTRO_NAME WSL is already started~~~"
    fi

    local wsl_started_flag=/mnt/wsl/.wsl_started
    if [ ! -f $wsl_started_flag ]; then 
        fmt_info "Win10 WSL service is starting~~~"
        fmt_info "Configing none now"
        touch $wsl_started_flag    
    else
        fmt_info "Win10 WSL service is already started~~~"
    fi
fi

