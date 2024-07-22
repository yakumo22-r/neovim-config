" base
syntax on
filetype plugin indent on
set number
set relativenumber
set clipboard=unnamed
set cursorline

set hlsearch
set showmatch

" tabs
set autoindent
set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4
set backspace=indent,eol,start
set smartindent
set list

set scrolloff=2
set iskeyword+=-
set undofile

" Set leader key to space
let mapleader = " "

" Shield keys
nnoremap <silent> z <Nop>
nnoremap <silent> q <Nop>

" Window navigation
nnoremap <silent> <Leader>h <C-w>h
nnoremap <silent> <Leader>l <C-w>l
nnoremap <silent> <Leader>j <C-w>j
nnoremap <silent> <Leader>k <C-w>k

nnoremap <silent> <Leader>sk :set nosplitbelow<CR>:split<CR>
nnoremap <silent> <Leader>sj :set splitbelow<CR>:split<CR>
nnoremap <silent> <Leader>sh :set nosplitright<CR>:vsplit<CR>
nnoremap <silent> <Leader>sl :set splitright<CR>:vsplit<CR>

nnoremap <silent> <Leader>srh <C-w>b<C-w>K
nnoremap <silent> <Leader>srv <C-w>b<C-w>H

" Move line
nnoremap <silent> <A-up> :res +2<CR>
nnoremap <silent> <A-down> :res -2<CR>
nnoremap <silent> <A-left> :vertical resize -2<CR>
nnoremap <silent> <A-right> :vertical resize +2<CR>

" Hide search highlight
nnoremap <silent> <Leader><CR> :nohlsearch<CR>
vnoremap <silent> <Leader><CR> :nohlsearch<CR>

" Quick q! wq w
nnoremap <silent> W :w<CR>
nnoremap <silent> Q :q!<CR>

" Move
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" Quick movement
nnoremap <silent> L $
vnoremap <silent> L $
nnoremap <silent> H ^
vnoremap <silent> H ^

" Move text
vnoremap <silent> < <gv
vnoremap <silent> > >gv

nnoremap <silent> <A-j> :m .+1<CR>==
nnoremap <silent> <A-k> :m .-2<CR>==
vnoremap <silent> <A-j> :m '>+1<CR>gv=gv
vnoremap <silent> <A-k> :m '<-2<CR>gv=gv

" Copy
nnoremap <silent> d "_d
vnoremap <silent> d "_d
nnoremap <silent> s "_s
vnoremap <silent> s "_s
nnoremap <silent> c "_c
vnoremap <silent> c "_c
vnoremap <silent> p "_dp
vnoremap <silent> P "_dP

" ({["'
inoremap <silent> {} {}<Esc>i
inoremap <silent> [] []<Esc>i
inoremap <silent> <> <><Esc>i
inoremap <silent> () ()<Esc>i
inoremap <silent> "" ""<Esc>i
inoremap <silent> '' ''<Esc>i
inoremap <silent> {<CR> {\n}<Esc>O
inoremap <silent> [<CR> [\n]<Esc>O
inoremap <silent> <<CR> <\n><Esc>O
inoremap <silent> (<CR> (\n)<Esc>O
inoremap <silent> {; {\n};<Esc>O
inoremap <silent> [; [\n];<Esc>O
inoremap <silent> <; <\n>;<Esc>O
inoremap <silent> (; (\n);<Esc>O

au BufRead,BufNewFile *.lua						set filetype=lua
au BufRead,BufNewFile *.lua.txt					set filetype=lua
au BufRead,BufNewFile *.zsh					    set filetype=sh
au BufRead,BufNewFile .zshrc					set filetype=sh
cnoreabbrev wqq wqa
cnoreabbrev qq qa
cnoreabbrev qqq qa!

