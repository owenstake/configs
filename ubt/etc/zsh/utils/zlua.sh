# lua setting
found_file=$(search_file $InstallDir z.lua)
if [ $? -eq 0 ] ; then
    export ZLUA_SCRIPT="$found_file"
    fmt_info "ZLUA_SCRIPT=$ZLUA_SCRIPT"
else
    fmt_error "No found z.lua"
    return
fi
# export RANGER_ZLUA=${ZLUA_SCRIPT:-"~/.zplug/repos/skywind3000/z.lua/z.lua"}
export _ZL_ROOT_MARKERS=".git,.svn,.hg,.root,package.json"    # for `z -b` to return to root dir
export _ZL_ECHO=1
export _ZL_DATA=$InstallDir/.zlua
eval "$(lua $ZLUA_SCRIPT --init ${SHELL##*/} enhanced once fzf)"
