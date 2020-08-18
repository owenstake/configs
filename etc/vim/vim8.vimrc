" Before plugin load {{{
    " 如果没安装过vim-plug， 则下载安装
    if empty(glob('~/.vim/autoload/plug.vim'))
        !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \https://raw.GitHub.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif

    " 将先导键映射为空格键
    let mapleader = "\<space>"
" }}}


" Plugins load {{{
    call plug#begin('~/.vim/plugged') 

    " Make sure you use single quotes

    " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
    Plug 'junegunn/vim-easy-align'

    " Any valid git URL is allowed
    Plug 'https://github.com/junegunn/vim-github-dashboard.git'

    " Multiple Plug commands can be written in a single line using | separators
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

    " On-demand loading
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

    " Using a non-master branch
    Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

    " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
    Plug 'fatih/vim-go', { 'tag': '*' }

    " Plugin options
    Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

    " Plugin outside ~/.vim/plugged with post-update hook
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
    " Unmanaged plugin (manually installed and updated)
    Plug '~/my-prototype-plugin'

    Plug 'ctrlpvim/ctrlp.vim'

    " let g:plug_timeout = 300 " 为YouCompleteMe增加vim-plug的超时时间
    " Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

    Plug 'sjl/gundo.vim' " undo tree

    Plug 'easymotion/vim-easymotion' " for motion

    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-surround'

    Plug 'vim-airline/vim-airline'

    Plug 'mileszs/ack.vim'

    Plug 'flazz/vim-colorschemes'
    Plug 'vim-scripts/ScrollColors'

    Plug 'andymass/vim-matchup'

    Plug 'tpope/vim-unimpaired'

    " gtags config {{{ 
        Plug 'ludovicchabant/vim-gutentags'
        Plug 'skywind3000/gutentags_plus'
        Plug 'skywind3000/vim-preview'

        " enable gtags module
        let g:gutentags_modules = ['ctags', 'gtags_cscope']

        " config project root markers.
        let g:gutentags_project_root = ['.root']

        " generate datebases in my cache directory, prevent gtags files polluting my project
        let g:gutentags_cache_dir = expand('~/.cache/tags')

        " change focus to quickfix window after search (optional).
        let g:gutentags_plus_switch = 1
    " }}}

    Plug 'morhetz/gruvbox'
    Plug 'altercation/vim-colors-solarized'

    Plug 'justinmk/vim-syntax-extra'
    Plug 'octol/vim-cpp-enhanced-highlight'

    Plug 'dense-analysis/ale'

    " Initialize plugin system
    call plug#end()
" }}} end of plugin

" key binding {{{
    " 用leader-w保存文件
    " noremap <leader>w :w<cr>

    inoremap jk <esc>
    inoremap kj <esc>
    inoremap jj <esc>
    inoremap kk <esc>


    " 用先导键重新映射CtrlP的行为
    let g:ctrlp_map = '<leader>p'
    noremap <leader>p :CtrlP<cr>
    noremap <leader>b :CtrlPBuffer<cr>
    noremap <leader>m :CtrlPMRU<cr>

    " vim command-line keymap
    cnoremap vic vsp $MYVIMRC
    cnoremap vis write \|source $MYVIMRC \| PlugInstall 

    if has('python3')
        let g:gundo_prefer_python3 = 1
    endif
    noremap <f5> :GundoToggle<cr> " 将Gundo映射到<F5>
" }}}

" format doc {{{
    set number
    " set relativenumber
    syntax on " 支持语法高亮显示
    filetype plugin indent on " 启用根据文件类型自动缩进
    set autoindent " 开始新行时处理缩进
    set expandtab " 将制表符Tab展开为空格， 这对于Python尤其有用
    set tabstop=4 " 要计算的空格数
    set shiftwidth=4 " 用于自动缩进的空格数
    set backspace=2 " 在多数终端上修正退格键Backspace的行为

    " set fdm=indent 
    autocmd BufRead *.vimrc set foldmethod=marker
    autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
    autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>

" }}}


" vim ui {{{
    set termguicolors

    " colorscheme gruvbox
    " colorscheme solarized
    " colorscheme murphy " 修改配色

    let g:solarized_termcolors=256

    syntax enable
    set background=dark
    colorscheme solarized

    autocmd filetype python echo "haha"
" }}}

" ale {{{
    let g:ale_linters_explicit = 1
    let g:ale_completion_delay = 500
    let g:ale_echo_delay = 20
    let g:ale_lint_delay = 500
    let g:ale_echo_msg_format = '[%linter%] %code: %%s'
    let g:ale_lint_on_text_changed = 'normal'
    let g:ale_lint_on_insert_leave = 1
    let g:airline#extensions#ale#enabled = 1

    let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
    let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
    let g:ale_c_cppcheck_options = ''
    let g:ale_cpp_cppcheck_options = ''

    let g:ale_linters = {
    \   'c++': ['clang'],
    \   'c': ['clang'],
    \   'python': ['pylint'],
    \}
" }}}

" auto save and reload .vimrc - https://zhuanlan.zhihu.com/p/98966660 {{{
    augroup Reload_Vimrc        " Group name.  Always use a unique name!  autocmd!                " Clear any preexisting autocommands from this group
        autocmd! BufWritePost $MYVIMRC source % | echom "Reloaded " . $MYVIMRC | redraw
        autocmd! BufWritePost $MYGVIMRC if has('gui_running') | so % | echom "Reloaded " . $MYGVIMRC | endif | redraw
    augroup END 
" }}}



