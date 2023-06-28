
" LeaderF config {{{
    " noremap <Leader>p   :LeaderfFile<cr>
    noremap <Leader>kk  :LeaderfFile<cr>
    noremap <Leader>rr  :LeaderfMru<cr>
    noremap <Leader>fp  :LeaderfFunction!<cr>
    noremap <Leader>bb  :LeaderfBuffer<cr>
    noremap <Leader>ft  :LeaderfTag<cr>
    noremap <Leader>xm  :Leaderf command<cr>
    noremap <Leader>qq  :Leaderf rg<cr>

    noremap <leader>fr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
    noremap <leader>fd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
    noremap <leader>fo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
    noremap <leader>fn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
    noremap <leader>fp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>

    noremap q/          :Leaderf searchHistory<cr>
    noremap q:          :Leaderf cmdHistory<cr>

    " LeaderF
    let g:Lf_ReverseOrder         = 1
    let g:Lf_StlSeparator         = { 'left': '', 'right': '', 'font': '' }
    let g:Lf_RootMarkers          = ['.project', '.root', '.svn', '.git']
    let g:Lf_WorkingDirectoryMode = 'Ac'
    let g:Lf_WindowHeight         = 0.30
    let g:Lf_CacheDirectory       = expand('~/.vim/cache')
    let g:Lf_ShowRelativePath     = 0
    let g:Lf_HideHelp             = 1
    let g:Lf_StlColorscheme       = 'powerline'
    let g:Lf_PreviewResult        = {'Function':0, 'BufTag':0}
    let g:Lf_GtagsAutoGenerate    = 1
    let g:Lf_WindowPosition       = 'popup'
    let g:Lf_PreviewInPopup = 1
" }}}
