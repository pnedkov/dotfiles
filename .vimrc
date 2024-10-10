syntax on
colorscheme wildcharm

set mouse=r

set encoding=utf-8

set pastetoggle=<F12>

set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set expandtab
set cursorline

set hlsearch
set incsearch

set ruler

set number
" nnoremap <silent> <leader>n :set number!<CR>
nmap <silent> <leader>n :set number!<CR>

set cursorline
highlight CursorLineNR ctermfg=red

set showbreak=↪\ 
set listchars=tab:»\ ,eol:↲,nbsp:⎵,trail:•,extends:⟩,precedes:⟨
nmap <silent> <leader>l :set invlist<CR>

autocmd FileType yml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd Filetype gitconfig setlocal ts=8 sts=0 sw=8 noet
autocmd FileType gitcommit setlocal tw=72

" automatically move the cursor to the last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

