" Auto Download vim-plug if no vim-plug exists.
if has('win64') || has('win32')
    if empty(glob('~/vimfiles/autoload/plug.vim'))
        !powershell.exe -Command 
          \ "iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | New-Item $HOME/vimfiles/autoload/plug.vim -Force"
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
else
    if empty(glob('~/.vim/autoload/plug.vim'))
      !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
          \ https://raw.GitHub.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endif

" Plugins load {{{
call plug#begin()
" general setting {{{
    Plug 'mhinz/vim-startify'   " The fancy start screen for Vim
    Plug 'vim-scripts/ReplaceWithRegister'
    Plug 'dhruvasagar/vim-zoom'
    Plug 'mbbill/undotree'
"}}}

" markdown{{{
    Plug 'godlygeek/tabular' " must before vim-markdown
    Plug 'plasticboy/vim-markdown'
    Plug 'mzlogin/vim-markdown-toc'

    " HOST Browser is best for markdown preview in WSL
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
"}}}

" vim-easy-align - Shorthand notation; fetches https://github.com/junegunn/vim-easy-align{{{
    Plug 'junegunn/vim-easy-align'
"}}}

    " On-demand loading
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    Plug 'easymotion/vim-easymotion' " for motion <Leader><Leader>w
    Plug 'rhysd/accelerated-jk'
    nmap j <Plug>(accelerated_jk_gj)
    nmap k <Plug>(accelerated_jk_gk)

" {{{ basic trick
    Plug 'vim-airline/vim-airline'
    Plug 'tpope/vim-unimpaired' " ]b ]c ]n ]l
    Plug 'nelstrom/vim-visual-star-search' " "*"
    Plug 'tpope/vim-repeat'  " dot for repeat more common
    Plug 'tpope/vim-surround' " ysw
    Plug 'andymass/vim-matchup'  " %
    Plug 'tpope/vim-abolish'  " :%S/{man,dog}/{dog,man}/g
    Plug 'tpope/vim-fugitive' " Gblame
    Plug 'airblade/vim-gitgutter' " Git Diff Show Sign +~-

    " vim-textobj-user
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'      " vii
    Plug 'kana/vim-textobj-syntax'
    Plug 'kana/vim-textobj-function',  " vif
        \ { 'for':['c', 'cpp', 'vim', 'java'] }
    Plug 'sgur/vim-textobj-parameter'   " vi,

    " Enhanced C syntax
    Plug 'justinmk/vim-syntax-extra'
    Plug 'octol/vim-cpp-enhanced-highlight'
" }}}

" syntax check
Plug 'neomake/neomake'
" Plug 'dense-analysis/ale'

" Commnentary
Plug 'tpope/vim-commentary' " gcc
autocmd FileType java,c,cpp set commentstring=//\ %s " comment style //
autocmd FileType autohotkey set commentstring=\;\ %s " comment style //

" colorschemes {{{
    Plug 'flazz/vim-colorschemes'
    Plug 'vim-scripts/ScrollColors'
    Plug 'morhetz/gruvbox'
    Plug 'crusoexia/vim-monokai'   " default now
    Plug 'altercation/vim-colors-solarized'
" }}}

"{{{ Tabular Align
    Plug 'godlygeek/tabular'  " easy-align is better
    if exists(":Tabularize")   " directly use :Tabularize /=
        " map for nmap and vmap
        map <Leader>a= :Tabularize /=<CR>
        map <Leader>a: :Tabularize /:\zs<CR>
    endif
"}}}

" show num convert
Plug 'glts/vim-magnum'
Plug 'glts/vim-radical' " gA decimal:"crd" hex:"crx" octal:"cro" binary:"crb"

" GTAGS config {{{
    Plug 'ludovicchabant/vim-gutentags'
    Plug 'skywind3000/gutentags_plus'
    Plug 'skywind3000/vim-preview'
" }}}

" {{{ LeaderF
    Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
" }}}

" snippets {{{
    Plug 'honza/vim-snippets' " massive common snippets
" }}}

    Plug 'dhruvasagar/vim-table-mode'  " <Leader>tm  for  :TableModeToggle
    Plug 'owenstake/md-img-paste.vim'
    Plug 'junegunn/goyo.vim'
    Plug 'dkarter/bullets.vim'         " <leader>x for checkbox
    Plug 'kshenoy/vim-signature'       " bookmarker
    Plug 'vim-latex/vim-latex'
    Plug 'vim-scripts/DrawIt'
    Plug 'preservim/tagbar'
" Plug 'lyokha/vim-xkbswitch'
" let g:XkbSwitchEnabled =0

" Initialize plugin system
call plug#end()
" }}} end of plugin

" source plugin config file
source <sfile>:p:h/fzf.vim
source <sfile>:p:h/git.vim
source <sfile>:p:h/coc.vim
source <sfile>:p:h/vim-preview.vim
source <sfile>:p:h/leaderf.vim
source <sfile>:p:h/gtags.vim
source <sfile>:p:h/table.vim
source <sfile>:p:h/misc.vim

