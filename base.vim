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
set nolist

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
nnoremap <silent> Q :q!<CR>

" Move
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" Quick movement
nnoremap <silent> <C-j> 5j
nnoremap <silent> <C-k> 5k
nnoremap <silent> <C-l> 2w
nnoremap <silent> <C-h> 2b

" Move text
nnoremap <silent> < <<
nnoremap <silent> > >>
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
inoremap <silent> {<space> {}<Esc>i 
inoremap <silent> [<space> []<Esc>i
inoremap <silent> <<space> <><Esc>i
inoremap <silent> (<space> ()<Esc>i
inoremap <silent> "<space> ""<Esc>i
inoremap <silent> '<space> ''<Esc>i
inoremap <silent> {<CR> {<CR>}<Esc>O
inoremap <silent> [<CR> [<CR>]<Esc>O
inoremap <silent> <<CR> <<CR>><Esc>O
inoremap <silent> (<CR> (<CR>)<Esc>O
inoremap <silent> {; {<CR>};<Esc>O
inoremap <silent> [; [<CR>];<Esc>O
inoremap <silent> <; <<CR>>;<Esc>O
inoremap <silent> (; (<CR>);<Esc>O

"Invoker!!!"
nnoremap <silent> qqwrv :qa<CR>
nnoremap <silent> <Leader>qqq :qa<CR>
nnoremap <silent> <Leader>www :wqa<CR>
nnoremap <silent> <Leader>eee :qa!<CR>

vnoremap <silent> q <Esc>

au BufRead,BufNewFile *.lua						set filetype=lua
au BufRead,BufNewFile *.lua.txt					set filetype=lua
au BufRead,BufNewFile *.zsh					    set filetype=sh
au BufRead,BufNewFile .zshrc					set filetype=sh

highlight Visual ctermfg=NONE ctermbg=darkgray

function! Terminal_MetaMode(mode)
    set ttimeout
    if $TMUX != ''
        set ttimeoutlen=30
    elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
        set ttimeoutlen=80
    endif
    if has('nvim') || has('gui_running')
        return
    endif
    function! s:metacode(mode, key)
        if a:mode == 0
            exec "set <M-".a:key.">=\e".a:key
        else
            exec "set <M-".a:key.">=\e]{0}".a:key."~"
        endif
    endfunc
    for i in range(10)
        call s:metacode(a:mode, nr2char(char2nr('0') + i))
    endfor
    for i in range(26)
        call s:metacode(a:mode, nr2char(char2nr('a') + i))
        call s:metacode(a:mode, nr2char(char2nr('A') + i))
    endfor
    if a:mode != 0
        for c in [',', '.', '/', ';', '[', ']', '{', '}']
            call s:metacode(a:mode, c)
        endfor
        for c in ['?', ':', '-', '_']
            call s:metacode(a:mode, c)
        endfor
    else
        for c in [',', '.', '/', ';', '{', '}']
            call s:metacode(a:mode, c)
        endfor
        for c in ['?', ':', '-', '_']
            call s:metacode(a:mode, c)
        endfor
    endif
endfunc


call Terminal_MetaMode(0)
