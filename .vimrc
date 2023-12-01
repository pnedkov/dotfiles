set mouse=r

syntax on
colorscheme koehler

set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set expandtab
set cursorline

set hlsearch
set incsearch

set pastetoggle=<F2>

autocmd FileType yml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype gitconfig setlocal ts=8 sts=0 sw=8 noet
