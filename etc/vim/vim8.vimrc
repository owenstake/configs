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

    " vim-easy-align - Shorthand notation; fetches https://github.com/junegunn/vim-easy-align{{{
        Plug 'junegunn/vim-easy-align'
        " Start interactive EasyAlign in visual mode (e.g. vipga)
        xmap ga <Plug>(EasyAlign)

        " Start interactive EasyAlign for a motion/text object (e.g. gaip)
        nmap ga <Plug>(EasyAlign)
    "}}}
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

    " Plug 'ctrlpvim/ctrlp.vim'
    "{{{ YouCompleteMe
        let g:plug_timeout = 300 " 为YouCompleteMe增加vim-plug的超时时间
        Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

        let g:ycm_add_preview_to_completeopt                    = 0
        let g:ycm_show_diagnostics_ui                           = 0
        let g:ycm_server_log_level                              = 'info'
        let g:ycm_min_num_identifier_candidate_chars            = 2
        let g:ycm_collect_identifiers_from_comments_and_strings = 1
        let g:ycm_complete_in_strings                           = 1

        " let g:ycm_key_invoke_completion = '<c-z>'
        set completeopt=menu,menuone

        " noremap <c-z> <NOP>

        let g:ycm_semantic_triggers =  {
                   \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
                   \ 'cs,lua,javascript': ['re!\w{2}'],
                   \ }
        "}}}
    "
    Plug 'sjl/gundo.vim' " undo tree

    Plug 'easymotion/vim-easymotion' " for motion

    Plug 'tpope/vim-commentary' " gcc
    autocmd FileType java,c,cpp set commentstring=//\ %s

    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-speeddating' "     
    Plug 'tpope/vim-repeat'

    Plug 'glts/vim-magnum'
    Plug 'glts/vim-radical' " gA decimal:"crd" hex:"crx" octal:"cro" binary:"crb"

    Plug 'vim-airline/vim-airline'

    Plug 'mileszs/ack.vim'

    Plug 'andymass/vim-matchup'

    Plug 'tpope/vim-unimpaired' " ]b ]c ]n ]l

    Plug 'nelstrom/vim-visual-star-search' " "*"

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

    " colorschemes{{{
        Plug 'flazz/vim-colorschemes'
        Plug 'vim-scripts/ScrollColors'
        Plug 'morhetz/gruvbox'
        Plug 'crusoexia/vim-monokai'
        Plug 'altercation/vim-colors-solarized'
    "}}}
    
    Plug 'justinmk/vim-syntax-extra'
    Plug 'octol/vim-cpp-enhanced-highlight'

    " Plug 'dense-analysis/ale'
    Plug 'neomake/neomake'
    " {{{ LeaderF
        Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }

        noremap <Leader>p   :LeaderfFile<cr>
        noremap <Leader>ff  :LeaderfFile<cr>
        noremap <Leader>fm  :LeaderfMru<cr>
        noremap <Leader>fp  :LeaderfFunction!<cr>
        noremap <Leader>fb  :LeaderfBuffer<cr>
        noremap <Leader>ft  :LeaderfTag<cr>
        noremap q/          :Leaderf searchHistory<cr>
        noremap q:          :Leaderf cmdHistory<cr>

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
    " }}}


    " {{{ vim-signify for git show
        if has('nvim') || has('patch-8.0.902')
          Plug 'mhinz/vim-signify'
        else
          Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
        endif
        " default updatetime 4000ms is not good for async update
        set updatetime=100
    " }}}
    " {{{ vim-textobj-user
        Plug 'kana/vim-textobj-user'
        Plug 'kana/vim-textobj-indent'      " vii
        Plug 'kana/vim-textobj-syntax'  
        Plug 'kana/vim-textobj-function',  " vif
            \ { 'for':['c', 'cpp', 'vim', 'java'] }  
        Plug 'sgur/vim-textobj-parameter'   " vi,
    " }}}

    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
    Plug 'honza/vim-snippets' "massive common snippets

    "{{{ Tabular
        Plug 'godlygeek/tabular'
        if exists(":Tabularize")
            nmap <Leader>a= :Tabularize /=<CR>
            vmap <Leader>a= :Tabularize /=<CR>
            nmap <Leader>a: :Tabularize /:\zs<CR>
            vmap <Leader>a: :Tabularize /:\zs<CR>
        endif

        inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

        function! s:align()
            let p = '^\s*|\s.*\s|\s*$'
            if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
                let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
                let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
                Tabularize/|/l1
                normal! 0
                call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
            endif
        endfunction
    "}}}
    " Initialize plugin system
    call plug#end()
" }}} end of plugin

" basic setup {{{ 
"}}}

" key binding {{{
    " 用leader-w保存文件
    " noremap <leader>w :w<cr>
    
    " vim-commentary key map
    vmap gcc gc

    " history scoll
    cnoremap <C-p> <Up> 
    cnoremap <C-n> <Down>
    
    " %% the dirname for eth current buf-file. It is so intuitive
    cnoremap <expr> %% getcmdtype( ) == ':' ? expand('%:h').'/' : '%%'

    " for regexp very-magic-mode
    cnoremap s/ s/\v
    nnoremap / /\v

    " for <ese> in insert mode
    inoremap jk <esc>
    inoremap kj <esc>
    inoremap jj <esc>
    inoremap kk <esc>

    noremap <leader>q :q<cr>

    " 用先导键重新映射CtrlP的行为
    " let g:ctrlp_map = '<leader>p'
    noremap <leader>p :CtrlP<cr>
    noremap <leader>b :CtrlPBuffer<cr>
    noremap <leader>m :CtrlPMRU<cr>

    " vim command-line keymap
    cnoremap vic vsp $MYVIMRC
    cnoremap vis write \|source $MYVIMRC \| PlugInstall 
    cnoremap gca Gcommit -a -v
    cnoremap gp Gpush
    cnoremap gl Gpull

    " Gundo undo tree setup
    if has('python3')
        let g:gundo_prefer_python3 = 1
    endif
    noremap <f5> :GundoToggle<cr> " 将Gundo映射到<F5>

    " keymap vim-preview
    autocmd FileType    qf    nnoremap <silent><buffer>  p  :PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer>  P  :PreviewClose<cr>
    autocmd FileType    qf    nnoremap <silent><buffer> d j:PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer> u k:PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer>  q  :PreviewClose<cr>:q<cr>
    autocmd FileType vim-plug nnoremap <silent><buffer>  q  :q<cr>

" }}}

" format doc {{{
    set hlsearch              " highlight search
    set number                " show line number
    set ignorecase            " set for case search
    set smartcase             " set for case search
                              " set relativenumber
    syntax on                 " 支持语法高亮显示
    filetype plugin indent on " 启用根据文件类型自动缩进
    filetype plugin on
    set autoindent            " 开始新行时处理缩进
    set expandtab             " 将制表符Tab展开为空格， 这对于Python尤其有用

    set tabstop    =4             " 要计算的空格数
    set shiftwidth =4          " 用于自动缩进的空格数
    set backspace  =2           " 在多数终端上修正退格键Backspace的行为
    set fdm        =indent
    autocmd BufRead *.vimrc set foldmethod=marker

" }}}


" vim ui {{{
    set cursorline  " highlight cursor position
    set cursorcolumn

    " set t_Co=256 " for 256colors
    " using a terminal which support truecolor like iterm2, enable the gui color
    " must be set for tmux vi color consistence
    set termguicolors 

    " colorscheme solarized
    " let g:solarized_termcolors=256

    set background=dark
    " colorscheme murphy " 修改配色
    " colorscheme gruvbox
    colorscheme monokai

    autocmd filetype python echo "haha"
" }}}

" ale {{{
    let g:ale_linters_explicit           = 1
    let g:ale_completion_delay           = 500
    let g:ale_echo_delay                 = 20
    let g:ale_lint_delay                 = 500
    let g:ale_echo_msg_format            = '[%linter%] %code: %%s'
    let g:ale_lint_on_text_changed       = 'normal'
    let g:ale_lint_on_insert_leave       = 1
    let g:airline#extensions#ale#enabled = 1

    let g:ale_c_gcc_options              = '-Wall -O2 -std=c99'
    let g:ale_cpp_gcc_options            = '-Wall -O2 -std=c++14'
    let g:ale_c_cppcheck_options         = ''
    let g:ale_cpp_cppcheck_options       = ''

    let g:ale_linters = {
    \   'c++': ['clang'],
    \   'c': ['clang'],
    \   'python': ['pylint'],
    \}
" }}}

" auto save and reload .vimrc - https://zhuanlan.zhihu.com/p/98966660 {{{
    " Group name.  Always use a unique name!  autocmd!                "
    " Clear any preexisting autocommands from this group
    augroup Reload_Vimrc     
        autocmd! BufWritePost $MYVIMRC source % | echom "Reloaded " . $MYVIMRC | redraw
        autocmd! BufWritePost $MYGVIMRC if has('gui_running') | so % | echom "Reloaded " . $MYGVIMRC | endif | redraw
    augroup END 
" }}}


