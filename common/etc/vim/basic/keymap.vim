
" Basic Key Map {{{
    " nnoremap <C-j> :m .+0<CR>
    noremap <C-j> a<esc>
    inoremap <C-j> <esc>a
    noremap <C-k> a<esc>
    inoremap <C-k> <esc>a

    " EMACS way editing line
    inoremap  <Right>
    inoremap  <Left>
    inoremap  <Home>
    inoremap  <End>

    inoremap jk <Esc>

    " EMACS way editing command line
    cnoremap  <Right>
    cnoremap  <Left>
    cnoremap  <Home>
    cnoremap  <End>

    nnoremap * *N
    nnoremap # #N

    nnoremap <Leader><Leader>a ga

    " history scoll for command-line mode
    cnoremap <C-p> <Up>
    cnoremap <C-n> <Down>

    " for scoll
    nnoremap <c-e> <c-e>j
    nnoremap <c-y> <c-y>k

    " j/k will move virtual lines (lines that wrap)
    noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
    noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

    " for regexp very-magic-mode
    cnoremap s/ s/\v
    nnoremap / /\v


    " buffer manage
    cnoremap bls ls
    cnoremap vsb vertical sb

    nnoremap t. :tabedit %<cr>
    nnoremap te :tabedit <cr>
    nnoremap tc :tabclose <cr>
    nnoremap to :tabonly <cr>
    nnoremap tm :tabmove <cr>
    nnoremap ts :tabs <cr>
    nnoremap tf :tabfirst <cr>
    nnoremap tl :tablast <cr>
    nnoremap tn :tabnext <cr>
    nnoremap tp :tabprevious <cr>

    " Allow saving of files as sudo when I forgot to start vim using sudo.
    " https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
    " cmap w!! w !sudo tee > /dev/null %
    cnoremap w!! w !sudo tee % > /dev/null
    cnoremap x!! x !sudo tee % > /dev/null

    cnoremap vic vsp $MYVIMRC
    cnoremap vis write \|source $MYVIMRC \| PlugInstall

    map <leader>x1 :only<cr>
    map <leader>x2 :vsplit<cr>

" }}}
