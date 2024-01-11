if command_exists atuin ; then
    fmt_info "Load atuin"
    eval "$(atuin init $CURRENT_SHELL)"
fi
