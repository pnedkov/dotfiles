syntax on
set background=dark
colorscheme wildcharm

nnoremap <SPACE> <Nop>
let mapleader=" "

set mouse=r

set encoding=utf-8

set pastetoggle=<F12>

set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set expandtab
set cursorline

set hlsearch
set incsearch

set showcmd

set ruler

set number relativenumber
" nnoremap <silent> <leader>n :set number!<CR>
nmap <silent> <leader>n :set number! relativenumber!<CR>

set cursorline
highlight CursorLineNR ctermfg=red

set showbreak=↪\ 
set listchars=tab:»\ ,eol:↲,nbsp:⎵,trail:•,extends:⟩,precedes:⟨
nmap <silent> <leader>l :set invlist<CR>

nmap <silent> <leader>q :qa!<CR>
nmap <silent> <leader>w :w<CR>
nmap <silent> <leader>x :x<CR>

autocmd FileType yml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype gitconfig setlocal ts=8 sts=0 sw=8 noet
autocmd FileType gitcommit setlocal tw=72

" automatically move the cursor to the last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

