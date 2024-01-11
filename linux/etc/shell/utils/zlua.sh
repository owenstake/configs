# lua setting
found_file=$(search_file $InstallDir z.lua)
if [ $? -eq 0 ] ; then
    export ZLUA_SCRIPT="$found_file"
    fmt_info "Load zlua"
else
    fmt_error "No found z.lua"
    return
fi

# zlua {{{
    # <ctrl-t><ctrl-t> for zf in fzf
    # already define in z.lua
    # zz='z -i'  \
    # zf='z -I'  \
    # zb='z -b'  \
    # zbi='z -b -i'  \
    # zbf='z -b -I'  \
    # zh='z -I -t .'  \
    # zzc='zz -c' \
    alias                          \
    zb='z -b'                      \
    zi='z -i'                      \
    zl='z -l'                      \
    zc='z -c'                      \
    zcl='z -c -l'                  \
    zcf='z -c -I'                  \
    zch='z -c -I -t .'             \
    zd="cd $WinUserHome/Downloads" \
    zr="cd $WinUserHome/Desktop"   \
    zp="cd $WinUserWeiyun"         \
    zn="cd $WinUserWeiyun/my_note" \
# }}}

# export RANGER_ZLUA=${ZLUA_SCRIPT:-"~/.zplug/repos/skywind3000/z.lua/z.lua"}
export _ZL_ROOT_MARKERS=".git,.svn,.hg,.root,package.json"    # for `z -b` to return to root dir
export _ZL_ECHO=1
export _ZL_DATA=$InstallDir/.zlua
eval "$(lua $ZLUA_SCRIPT --init ${CURRENT_SHELL} enhanced once fzf)"


