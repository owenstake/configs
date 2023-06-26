
    " keymap vim-preview
    autocmd FileType    qf    nnoremap <silent><buffer>  p  :PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer>  P  :PreviewClose<cr>
    autocmd FileType    qf    nnoremap <silent><buffer> d j:PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer> u k:PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer>  q  :PreviewClose<cr>:q<cr>
    autocmd FileType vim-plug nnoremap <silent><buffer>  q  :q<cr>
