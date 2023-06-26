let mapleader = "\<space>"

inoremap jk <esc>

if has('win64') || has('win32')
    if empty(glob(stdpath('data') . '/plugged'))
        echo "Downloading vim-plug"
        let PLUG_VIM_FILE = stdpath('data') . '/site/autoload/plug.vim'
        " execute '!powershell.exe -Command "iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | New-Item ' . PLUG_VIM_FILE . ' -Force"'
        execute '!powershell.exe -Command "iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | New-Item ' . PLUG_VIM_FILE . ' -Force"'
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
else
    if empty(glob(stdpath('data') . '/plugged'))
        !curl -fLo ~/.var/app/io.neovim.nvim/data/nvim/site/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endif

call plug#begin()
    Plug 'junegunn/vim-easy-align'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary' " gcc
    autocmd FileType java,c,cpp set commentstring=//\ %s " comment style //
    autocmd FileType autohotkey set commentstring=\;\ %s " comment style //
    Plug 'easymotion/vim-easymotion' " for motion <Leader><Leader>w
    Plug 'godlygeek/tabular' " must before vim-markdown
    Plug 'tpope/vim-unimpaired' " ]b ]c ]n ]l
	Plug 'kshenoy/vim-signature' " bookmarker

call plug#end()


if exists('g:vscode')
    " VSCode extension
    nnoremap <leader>ww <Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>
else
    " ordinary Neovim
endif
