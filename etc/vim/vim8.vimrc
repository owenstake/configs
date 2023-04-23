" DEBUG for vim :messages

let mapleader = "\<space>"

" Before plugin load {{{
    " if no vim-plug, then download
    if empty(glob('~/.vim/autoload/plug.vim'))
        !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.GitHub.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif

" }}}

" Plugins load {{{
    call plug#begin('~/.vim/plugged')
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

        " HOST CHOME is best for markdown preview in WSL
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

    Plug 'dhruvasagar/vim-table-mode'
    Plug 'owenstake/md-img-paste.vim'
    Plug 'junegunn/goyo.vim'
    Plug 'dkarter/bullets.vim'  " <leader>x for checkbox
    Plug 'kshenoy/vim-signature' " bookmarker
    Plug 'vim-latex/vim-latex'
    " Plug 'lyokha/vim-xkbswitch'
    " let g:XkbSwitchEnabled =0

    " Initialize plugin system
    call plug#end()
" }}} end of plugin


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

    nnoremap * *N
    nnoremap # #N

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

    " for <ese> in insert mode
    inoremap jk <esc>
    " inoremap kj <esc>

    " buffer manage
    cnoremap bls ls
    cnoremap vsb vertical sb

    " tab manage
    " cnoremap te tabedit
    " cnoremap tc tabclose
    " cnoremap to tabonly
    " cnoremap tm tabmove
    " cnoremap ts tabs
    " cnoremap tf tabfirst
    " cnoremap tl tablast

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
    cmap w!! w !sudo tee % > /dev/null
    cmap x!! x !sudo tee % > /dev/null
" }}}

" Special Key Map and config {{{
"
    " GitGutter Hunk config {{{
        " some default
        " <Leader>hs stage hunk
        " <Leader>hu unstage hunk
        " <Leader>hp preview diff hunk
        " vic vac select hunk
        nmap ]c <Plug>(GitGutterNextHunk) " next change
        nmap [c <Plug>(GitGutterPrevHunk)
        nmap ]h <Plug>(GitGutterNextHunk) " next change
        nmap [h <Plug>(GitGutterPrevHunk)
        let g:gitgutter_preview_win_floating = 1
    " }}}

    nmap gp <Plug>ReplaceWithRegisterOperator
    nmap gpp <Plug>ReplaceWithRegisterLine
    " nmap gss <plug>SubstituteLine
    " nmap gs <plug>SubstituteOverMotionMap

    " nmap : :Leaderf command<cr>
    nnoremap <Leader><Leader>a ga

    " vim-commentary key map
    vmap gcc gc

    " %% the dirname for eth current buf-file. It is so intuitive
    cnoremap <expr> %% getcmdtype( ) == ':' ? expand('%:h').'/' : '%%'

    noremap <leader>q :q<cr>

    " vim command-line keymap
    cnoremap vic vsp $MYVIMRC
    cnoremap vis write \|source $MYVIMRC \| PlugInstall
    cnoremap gca Gcommit -a -v
    cnoremap gp Gpush
    cnoremap gl Gpull
    cnoremap cmd CocCommand

    " undotree
    if has("persistent_undo")
       let target_path = expand('~/.undodir')

        " create the directory and any parent directories
        " if the location does not exist.
        if !isdirectory(target_path)
            call mkdir(target_path, "p", 0700)
        endif

        let &undodir=target_path
        set undofile
    endif

    " keymap vim-preview
    autocmd FileType    qf    nnoremap <silent><buffer>  p  :PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer>  P  :PreviewClose<cr>
    autocmd FileType    qf    nnoremap <silent><buffer> d j:PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer> u k:PreviewQuickfix<cr>
    autocmd FileType    qf    nnoremap <silent><buffer>  q  :PreviewClose<cr>:q<cr>
    autocmd FileType vim-plug nnoremap <silent><buffer>  q  :q<cr>

    " config for ultisnippet
    "let g:UltiSnipsExpandTrigger = '<c-s>'
    """设置向后跳转
    "let g:UltiSnipsJumpForwardTrigger = '<c-j>'
    """设置向前跳转
    "let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

    ""设置文件
    "let g:UltiSnipsSnippetDirectories=["/home/z/.vim/plugged/ultisnips"]
    "let g:UltiSnipsEditSplit="vertical"

    " fzf-vim -- https://github.com/junegunn/fzf.vim#example-advanced-rg-command
    " Mapping selecting mappings
    nmap <leader><tab> <plug>(fzf-maps-n)
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)
    " Insert mode completion
    imap <c-x><c-k> <plug>(fzf-complete-word)
    imap <c-x><c-f> <plug>(fzf-complete-path)
    imap <c-x><c-l> <plug>(fzf-complete-line)

" }}}

" Basic Format Doc {{{
    set clipboard=unnamedplus " clip interact with system
    set hlsearch              " highlight search
    set number                " show line number
    set cc=80                 " set max charactors per line
    set smartcase ignorecase  " set for case search
                              " set relativenumber
    syntax on
    filetype plugin indent on
    filetype plugin on
    set expandtab smarttab autoindent noswapfile nowrap nobackup  " expandtab to space, especially for python

    set tabstop    =4          " use for tab expand
    set shiftwidth =4          " use for >>
    set backspace  =2

    " Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
    set splitbelow splitright

    " add gbk zh encoding support - https://www.cnblogs.com/lepeCoder/p/7718827.html
    set fileencodings=utf-8,gbk

    " set foldmethod =indent
    autocmd BufRead,BufNewFile *.vimrc,*.conf,*.zshrc set foldmethod=marker

    " format: Automatically deletes all trailing whitespace and newlines at end of file on save.
        " autocmd BufWritePre * %s/\s\+$//e
        " autocmd BufWritepre * %s/\n\+\%$//e
" }}}

" Vim UI {{{
    set cursorcolumn cursorline  " highlight cursor position

    " set t_Co=256 " for 256colors
    " using a terminal which support truecolor like iterm2, enable the gui color
    " must be set for tmux vi color consistence
    set termguicolors

    set background=dark
    colorscheme monokai

    map <leader>x1 :only<cr>
    map <leader>x2 :vsplit<cr>
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

" Code auto-completion {{{
    " COC config {{{
    " if has('nvim')
        let g:coc_global_extensions = [
          \ 'coc-snippets',
          \ 'coc-pairs',
          \ 'coc-eslint',
          \ 'coc-prettier',
          \ 'coc-json',
          \ 'coc-translator',
          \ ]
          " \ 'coc-tsserver',
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
              \ coc#pum#visible() ? "\<C-n>" :
              \ <SID>check_back_space() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> coc#pum#visible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        inoremap <silent><expr> <c-space> coc#refresh()

        " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
        " Coc only does snippet and additional edit on confirm.
        inoremap <expr> <cr> coc#pum#visible() ? "\<C-y>" : "\<C-g>u\<CR>"
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
    " }}}
"}}}
"
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

" GTAGS config {{{
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

" if has('nvim')
"     echo 'we are in nvim'
" else
"     echo 'we are in vim8'
" endif

" From Luke Smith - https://github.com/LukeSmithxyz/voidrice/blob/master/.config/nvim/init.vim {{{
    " Disables automatic commenting on newline:
        " autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

    " Save file as sudo on files that require root permission
        cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
"}}}

" Dic - set auto complete in dic -- pratical vim {{{
    autocmd BufNewFile,BufRead *.txt set filetype=txt
    autocmd FileType txt set dictionary=~/.vim/dict/mydict.dict
    set dictionary=~/.vim/dict/mydict.dict
    set complete+=k"
" }}}

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

    function! s:isAtStartOfLine(mapping)
      let text_before_cursor = getline('.')[0 : col('.')-1]
      let mapping_pattern = '\V' . escape(a:mapping, '\')
      let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
      return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
    endfunction

    inoreabbrev <expr> <bar><bar>
              \ <SID>isAtStartOfLine('\|\|') ?
              \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
    inoreabbrev <expr> __
              \ <SID>isAtStartOfLine('__') ?
              \ '<c-o>:silent! TableModeDisable<cr>' : '__'
" }}}

"{{{
    imap <C-l> <Plug>(coc-snippets-expand)

"    " tab trigger snippets auto-completion
"    inoremap <silent><expr> <TAB>
"          \ pumvisible() ? coc#_select_confirm() :
"          \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
"          \ <SID>check_back_space() ? "\<TAB>" :
"          \ coc#refresh()
"
"    function! s:check_back_space() abort
"      let col = col('.') - 1
"      return !col || getline('.')[col - 1]  =~# '\s'
"    endfunction

    " let g:coc_snippet_next = '<c-j>'  " default c-j c-k is better,
    " let snippets.userSnippetsDirectory
"}}}

set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8

let g:coc_disable_startup_warning = 1


