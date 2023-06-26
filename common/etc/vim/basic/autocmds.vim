
" Dic - set auto complete in dic -- pratical vim {{{
    autocmd BufNewFile,BufRead *.txt set filetype=txt
    autocmd FileType txt set dictionary=~/.vim/dict/mydict.dict
    set dictionary=~/.vim/dict/mydict.dict
    set complete+=k"
" }}}

" Vim Hooks {{{
     " vimrc - auto save and reload .vimrc - https://zhuanlan.zhihu.com/p/98966660 {{{
        " Group name.  Always use a unique name!  autocmd!                "
        " Clear any preexisting autocommands from this group
        augroup Reload_Vimrc
            autocmd! BufWritePost $MYVIMRC source % | echom "Reloaded " . $MYVIMRC | redraw
            autocmd! BufWritePost $MYGVIMRC if has('gui_running') | so % | echom "Reloaded " . $MYGVIMRC | endif | redraw
        augroup END
    " }}}
" }}}

