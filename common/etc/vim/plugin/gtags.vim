
" GTAGS config {{{
    " enable gtags module
    " let g:gutentags_modules = ['ctags', 'gtags_cscope']
    let g:gutentags_modules = ['gtags_cscope']

    " config project root markers. If you don't want to generate tags, then touch file .notags in the project root.
    let g:gutentags_project_root = ['.root']

    " generate datebases in my cache directory, prevent gtags files polluting my project
    let g:gutentags_cache_dir = expand('~/.cache/tags')

    " change focus to quickfix window after search (optional).
    let g:gutentags_plus_switch = 1

    " add eternal library
    let $GTAGSLIBPATH = '/home/z/work/eth-78x/org_cpu_12_4_PL1/prj_ft_4.19/tmp/rootfs-build/linux-kernel-ft-4.19'

    " key-binding - disable the default keymaps and define new keymap
    let g:gutentags_plus_nomap = 1
    noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>
    noremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>
    noremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>
    noremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>
    noremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>
    noremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
    noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
    noremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>
    noremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>
    noremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>
" }}}
