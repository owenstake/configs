let mapleader = "\<space>"

" Basic Format Doc {{{
if has('clipboard')
    if has('win64') || has('win32')
        set clipboard=unnamed     " windows. win no have + reg, use " reg instead
    else
        set clipboard=unnamedplus " linux. x11 use + reg. clip interact with system
    endif
    " if has('unnamedplus')  " When possible use + register for copy-paste
    "     set clipboard=unnamed,unnamedplus
    " else         " On mac and Windows, use * register for copy-paste. Do no have + reg
    "     set clipboard=unnamed
    " endif
endif

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

    " fobbid commnet on new line
    set formatoptions-=r formatoptions-=c formatoptions-=o
" }}}


" From Luke Smith - https://github.com/LukeSmithxyz/voidrice/blob/master/.config/nvim/init.vim {{{
    " Disables automatic commenting on newline:
        " autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

"}}}
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
