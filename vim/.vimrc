syntax on
filetype plugin indent on
set background=dark
colorscheme wildcharm

nnoremap <SPACE> <Nop>
let mapleader=" "

set mouse=r

set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set expandtab
set cursorline
set hidden
set autoread
set splitbelow splitright
set scrolloff=3
set updatetime=300

set hlsearch incsearch
set ignorecase smartcase

if has('persistent_undo')
  let s:undo_dir = expand('~/.vim/undo')
  if !isdirectory(s:undo_dir)
    silent! call mkdir(s:undo_dir, 'p', 0700)
  endif
  if isdirectory(s:undo_dir)
    let &undodir = s:undo_dir . '//'
    set undofile
  endif
  unlet s:undo_dir
endif

set showcmd

set ruler

set number relativenumber
" nnoremap <silent> <leader>n :set number!<CR>
nnoremap <silent> <leader>n :set number! relativenumber!<CR>

highlight CursorLineNR ctermfg=red

set showbreak=↪\ 
set listchars=tab:»\ ,eol:↲,nbsp:⎵,trail:•,extends:⟩,precedes:⟨
nnoremap <silent> <leader>l :set invlist<CR>

nnoremap <silent> <leader>Q :qa!<CR>
nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> <leader>x :x<CR>

augroup filetype_settings
  autocmd!
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType gitconfig setlocal ts=8 sts=0 sw=8 noet
  autocmd FileType gitcommit setlocal tw=72
augroup END

augroup auto_reload
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * checktime
augroup END

if has('timers')
  if exists('s:auto_reload_timer')
    call timer_stop(s:auto_reload_timer)
  endif
  let s:auto_reload_timer = timer_start(
        \ 1000,
        \ {timer -> execute('checktime | redraw')},
        \ {'repeat': -1})
endif

" automatically move the cursor to the last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
