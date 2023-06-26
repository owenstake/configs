
    " GitGutter Hunk config {{{
        " some default
        " <Leader>hs stage hunk
        " <Leader>hu unstage hunk
        " <Leader>hp preview diff hunk
        " vic vac select hunk
        nmap ]c <Plug>(GitGutterNextHunk) " next change
        nmap [c <Plug>(GitGutterPrevHunk)
        nmap ]h <Plug>(GitGutterNextHunk) " next change
        nmap [h <Plug>(GitGutterPrevHunk)
        let g:gitgutter_preview_win_floating = 1
    " }}}

    " vim command-line keymap
    cnoremap gca Gcommit -a -v
    cnoremap gp Gpush
    cnoremap gl Gpull
