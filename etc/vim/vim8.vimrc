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
    "general settign {{{
        Plug 'mhinz/vim-startify'

        " It seems ussless for me now, I prefer tmux prefix"
        " Plug 'christoomey/vim-tmux-navigator'
    "}}}

    " markdown{{{
        Plug 'godlygeek/tabular' "必要插件，安装在vim-markdown前面
        Plug 'plasticboy/vim-markdown'
        Plug 'mzlogin/vim-markdown-toc'
        " It is duplicated."
        " Plug 'SirVer/ultisnips', {'for':'markdown'}
        "
        " Plug 'honza/vim-snippets'

        if has('nvim')
            Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
        else
            Plug 'iamcco/markdown-preview.vim'
        endif
    "}}}

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
    if !has('nvim')
        Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
    endif

    " On-demand loading
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

    " Using a non-master branch
    Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

    " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
    Plug 'fatih/vim-go', { 'tag': '*' }

    " Plugin options
    Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    " Unmanaged plugin (manually installed and updated)
    Plug '~/my-prototype-plugin'

    " plug for neovim
      Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " if has('nvim')
    "   Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " endif

    " Plug 'ctrlpvim/ctrlp.vim'
    "{{{ YouCompleteMe
    " if !has('nvim')
    "     let g:plug_timeout = 300 " 为YouCompleteMe增加vim-plug的超时时间
    "     Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

    "     let g:ycm_add_preview_to_completeopt                    = 0
    "     let g:ycm_show_diagnostics_ui                           = 0
    "     let g:ycm_server_log_level                              = 'info'
    "     let g:ycm_min_num_identifier_candidate_chars            = 2
    "     let g:ycm_collect_identifiers_from_comments_and_strings = 1
    "     let g:ycm_complete_in_strings                           = 1

    "     " let g:ycm_key_invoke_completion = '<c-z>'
    "     set completeopt=menu,menuone

    "     " noremap <c-z> <NOP>

    "     let g:ycm_semantic_triggers =  {
    "                \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
    "                \ 'cs,lua,javascript': ['re!\w{2}'],
    "                \ }
    " endif
    "}}}

    Plug 'sjl/gundo.vim' " undo tree

    Plug 'easymotion/vim-easymotion' " for motion
    Plug 'rhysd/accelerated-jk' " for motion
    nmap j <Plug>(accelerated_jk_gj)
    nmap k <Plug>(accelerated_jk_gk)

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
        noremap <Leader>fc  ::Leaderf command<cr>

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

        " inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

        " function! s:align()
        "     let p = '^\s*|\s.*\s|\s*$'
        "     if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
        "         let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
        "         let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
        "         Tabularize/|/l1
        "         normal! 0
        "         call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
        "     endif
        " endfunction

    "}}}
    " Initialize plugin system
    call plug#end()
" }}} end of plugin

" basic setup {{{
"}}}

" key binding {{{

    " Damian Conway's Die Blinkënmatchen: highlight matches
    " https://qastack.jp/vi/2761/set-cursor-colour-different-when-on-a-highlighted-word
    nnoremap <silent> n n:call HLNext(0.1)<cr>
    nnoremap <silent> N N:call HLNext(0.1)<cr>

    function! HLNext()
        let l:higroup = matchend(getline('.'), '\c'.@/, col('.')-1) == col('.')
                    \ ? 'SpellRare' : 'IncSearch'
        let b:cur_match = matchadd(l:higroup, '\c\%#'.@/, 101)
        redraw
        augroup HLNext
            autocmd CursorMoved <buffer>
                        \   execute 'silent! call matchdelete('.b:cur_match.')'
                        \ | redraw
                        \ | autocmd! HLNext
        augroup END
    endfunction
    nnoremap <silent> * *:call HLNext()<CR>
    nnoremap <silent> # #:call HLNext()<CR>
    nnoremap <silent> n n:call HLNext()<cr>
    nnoremap <silent> N N:call HLNext()<cr>

    " function! HLNext (blinktime)
    "   let target_pat = '\c\%#'.@/
    "   let ring = matchadd('ErrorMsg', target_pat, 101)
    "   redraw
    "   exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
    "   call matchdelete(ring)
    "   redraw
    " endfunction

    " config for ultisnippet
    "设置tab键为触发键
    let g:UltiSnipsExpandTrigger = '<c-s>'
    ""设置向后跳转键
    let g:UltiSnipsJumpForwardTrigger = '<c-j>'
    ""设置向前跳转键
    let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

    "设置文件目录
    let g:UltiSnipsSnippetDirectories=["/home/z/.vim/plugged/ultisnips"]
    "设置打开配置文件时为垂直打开
    let g:UltiSnipsEditSplit="vertical"

    nnoremap * *N
    nnoremap # #N

    " for scoll
    nnoremap <c-e> <c-e>j
    nnoremap <c-y> <c-y>k

    " j/k will move virtual lines (lines that wrap)
    noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
    noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

    " nmap : :Leaderf command<cr>
    nnoremap <Leader><Leader>a ga

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
    set smarttab
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


" coc config{{{
    " if has('nvim')
        let g:coc_global_extensions = [
          \ 'coc-snippets',
          \ 'coc-pairs',
          \ 'coc-tsserver',
          \ 'coc-eslint',
          \ 'coc-prettier',
          \ 'coc-json',
          \ ]
        " from readme
        " if hidden is not set, TextEdit might fail.
        set hidden " Some servers have issues with backup files, see #649 set nobackup set nowritebackup " Better display for messages set cmdheight=2 " You will have bad experience for diagnostic messages when it's default 4000.
        set updatetime=300

        " don't give |ins-completion-menu| messages.
        set shortmess+=c

        " always show signcolumns
        set signcolumn=yes

        " Use tab for trigger completion with characters ahead and navigate.
        " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
        inoremap <silent><expr> <TAB>
              \ pumvisible() ? "\<C-n>" :
              \ <SID>check_back_space() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        inoremap <silent><expr> <c-space> coc#refresh()

        " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
        " Coc only does snippet and additional edit on confirm.
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
        " Or use `complete_info` if your vim support it, like:
        " inoremap <expr> <cr> complete_nfo()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

        " Use `[g` and `]g` to navigate diagnostics
        nmap <silent> [g <Plug>(coc-diagnostic-prev)
        nmap <silent> ]g <Plug>(coc-diagnostic-next)

        " Remap keys for gotos
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        " nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)

        " Use K to show documentation in preview window
        nnoremap <silent> K :call <SID>show_documentation()<CR>

        function! s:show_documentation()
          if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
          else
            call CocAction('doHover')
          endif
        endfunction

        " Highlight symbol under cursor on CursorHold
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Remap for rename current word
        nmap <F2> <Plug>(coc-rename)

        " Remap for format selected region
        xmap <leader>f  <Plug>(coc-format-selected)
        nmap <leader>f  <Plug>(coc-format-selected)

        augroup mygroup
          autocmd!
          " Setup formatexpr specified filetype(s).
          autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
          " Update signature help on jump placeholder
          autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
        xmap <leader>a  <Plug>(coc-codeaction-selected)
        nmap <leader>a  <Plug>(coc-codeaction-selected)

        " Remap for do codeAction of current line
        nmap <leader>ac  <Plug>(coc-codeaction)
        " Fix autofix problem of current line
        nmap <leader>qf  <Plug>(coc-fix-current)

        " Create mappings for function text object, requires document symbols feature of languageserver.
        xmap if <Plug>(coc-funcobj-i)
        xmap af <Plug>(coc-funcobj-a)
        omap if <Plug>(coc-funcobj-i)
        omap af <Plug>(coc-funcobj-a)

        " Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
        nmap <silent> <C-d> <Plug>(coc-range-select)
        xmap <silent> <C-d> <Plug>(coc-range-select)

        " Use `:Format` to format current buffer
        command! -nargs=0 Format :call CocAction('format')

        " Use `:Fold` to fold current buffer
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)

        " use `:OR` for organize import of current buffer
        command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

        " Add status line support, for integration with other plugin, checkout `:h coc-status`
        set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

        " Using CocList
        " Show all diagnostics
        nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
        " Manage extensions
        nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
        " Show commands
        nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
        " Find symbol of current document
        nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
        " Search workspace symbols
        nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
        " Do default action for next item.
        nnoremap <silent> <space>j  :<C-u>CocNext<CR>
        " Do default action for previous item.
        nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
        " Resume latest coc list
        nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

        " unmap sth
        unmap <silent> <c-d>
    " endif
"}}}

if has('nvim')
    echo 'we are in nvim'
else
    echo 'we are in vim8'
endif

" From Luke Smith - https://github.com/LukeSmithxyz/voidrice/blob/master/.config/nvim/init.vim{{{
    " Disables automatic commenting on newline:
      autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

    " Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
        set splitbelow splitright

    " Save file as sudo on files that require root permission
        cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

    " Automatically deletes all trailing whitespace and newlines at end of file on save.
        " autocmd BufWritePre * %s/\s\+$//e
        "     autocmd BufWritepre * %s/\n\+\%$//e
"}}}

" EMACS way edit {{{
    inoremap  <Right>
    inoremap  <Left>
    inoremap  <Home>
    " inoremap  <End>
"}}}

let $GTAGSLIBPATH='/home/z/work/try/linux-2.6.39'

" add gbk zh encoding support - https://www.cnblogs.com/lepeCoder/p/7718827.html
set fileencodings=utf-8,gbk

" set auto complete in dic -- pratical vim {{{
autocmd BufNewFile,BufRead *.txt set filetype=txt
autocmd FileType txt set dictionary=~/.vim/dict/mydict.dict
set dictionary=~/.vim/dict/mydict.dict
set complete+=k"
" }}}
