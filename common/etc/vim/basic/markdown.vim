" {{{ markdown config
    " paste img
    function SetEnvforMarkdown()
        let g:mdip_imgdir = expand('%:r') . ".assets"
    endfunction
    autocmd BufEnter *.md call SetEnvforMarkdown()
    autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>

    " shortcut in insert mode for md marker
    "autocmd Filetype markdown map <leader>w yiWi[<esc>Ea](<esc>pa)
    autocmd Filetype markdown inoremap <buffer> <silent> ;, <++>
    autocmd Filetype markdown inoremap <buffer> ;f <Esc>/<++><CR>:nohlsearch<CR>"_c4l
    autocmd Filetype markdown inoremap <buffer> ;w <Esc>/ <++><CR>:nohlsearch<CR>"_c5l<CR>
    autocmd Filetype markdown inoremap <buffer> ;l ---<Enter><Enter>
    autocmd Filetype markdown inoremap <buffer> ;b **** <++><Esc>F*hi
    autocmd Filetype markdown inoremap <buffer> ;s ~~~~ <++><Esc>F~hi
    autocmd Filetype markdown inoremap <buffer> ;i ** <++><Esc>F*i
    autocmd Filetype markdown inoremap <buffer> ;x - [ ]
    autocmd Filetype markdown inoremap <buffer> ;c ```<Enter><++><Enter>```<Enter><++><Esc>3kA
    autocmd Filetype markdown inoremap <buffer> ;m ```mermaid<Enter><Enter>```<Enter><Enter><++><Esc>3kA
    autocmd Filetype markdown inoremap <buffer> ;q `` <++><Esc>F`i
    autocmd Filetype markdown inoremap <buffer> ;1 #<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap <buffer> ;2 ##<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap <buffer> ;3 ###<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap <buffer> ;4 ####<Space><Enter><++><Esc>kA
    autocmd Filetype markdown inoremap <buffer> <silent> ;t <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR>
    autocmd Filetype markdown inoremap <buffer> ;p ![](<++>) <++><Esc>F[a
    autocmd Filetype markdown inoremap <buffer> ;a [](<++> )<++><Esc>F[a
    " autocmd Filetype markdown inoremap <buffer> ;x - [X]
    " autocmd Filetype markdown inoremap <buffer> ;m - [ ]
" }}}
