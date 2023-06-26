
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


" set foldmethod =indent
autocmd BufRead,BufNewFile *.vimrc,*.conf,*.zshrc set foldmethod=marker

" format: Automatically deletes all trailing whitespace and newlines at end of file on save.
    " autocmd BufWritePre * %s/\s\+$//e
    " autocmd BufWritepre * %s/\n\+\%$//e
" }}}

" From Luke Smith - https://github.com/LukeSmithxyz/voidrice/blob/master/.config/nvim/init.vim {{{
" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
