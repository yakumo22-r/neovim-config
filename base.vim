" base
syntax on
filetype plugin indent on
set number
set relativenumber
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

" " blink cursor
" set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
"   \,a:blinkwait100-blinkoff400-blinkon250-Cursor/lCursor
"   \

set fileencodings=utf-8
set encoding=utf-8

set scrolloff=2
set iskeyword+=-
set undofile

" Set leader key to space
let mapleader = " "

nnoremap <silent> <A-b> ge
nnoremap <silent> <C-b> ge
nnoremap <silent> <C-B> gE
" nnoremap <silent> q <Nop>

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

" Quick q! wq w
nnoremap <silent> Q :q!<CR>

" Move
noremap <expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'
noremap <expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'

" Quick movement
noremap <silent> <C-j> 6j
noremap <silent> <C-k> 6k
noremap <silent> <C-l> 6w
noremap <silent> <C-h> 6b
noremap <silent> <C-y> 6<c-y>
noremap <silent> <C-e> 6<c-e>

inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-d> <Del>
inoremap <C-b> <BS>
inoremap <C-e> <Esc>ea
inoremap <C-w> <Esc>wa

" Move text
nnoremap <silent> < <<
nnoremap <silent> > >>
vnoremap <silent> < <gv
vnoremap <silent> > >gv

nnoremap <silent> <A-j> :m .+1<CR>==
nnoremap <silent> <A-k> :m .-2<CR>==
vnoremap <silent> <A-j> :m '>+1<CR>gv=gv
vnoremap <silent> <A-k> :m '<-2<CR>gv=gv

nnoremap <silent> <C-n> :m .+1<CR>==
nnoremap <silent> <C-m> :m .-2<CR>==
vnoremap <silent> <C-n> :m '>+1<CR>gv=gv
vnoremap <silent> <C-m> :m '<-2<CR>gv=gv

" Copy
nnoremap <silent> d "_d
vnoremap <silent> d "_d
nnoremap <silent> s "_s
vnoremap <silent> s "_s
nnoremap <silent> c "_c
vnoremap <silent> c "_c
vnoremap <silent> p "_dp
vnoremap <silent> P "_dP
nnoremap <silent> y "+y
vnoremap <silent> y "+y


vnoremap <silent> q <Esc>

nnoremap <C-\> :echo expand("%")<CR>

au BufRead,BufNewFile *.lua						set filetype=lua
au BufRead,BufNewFile *.lua.txt					set filetype=lua
au BufRead,BufNewFile *.zsh					    set filetype=sh
au BufRead,BufNewFile .zshrc					set filetype=sh

highlight Visual ctermfg=NONE ctermbg=darkgray


if has('win32')
    set clipboard=unnamedplus
else
    function! s:raw_echo(str)
        if has('win32') && has('nvim')
            call chansend(v:stderr, a:str)
        else
            if filewritable('/dev/fd/2')
                call writefile([a:str], '/dev/fd/2', 'b')
            else
                exec("silent! !echo " . shellescape(a:str))
                redraw!
            endif
        endif
    endfunction

    function! s:OSC52()
        let c = join(v:event.regcontents,"\n")
        let c64 = system("base64", c)
        let s = "\e]52;c;" . trim(c64) . "\x07"
        call s:raw_echo(s)
    endfunction

    autocmd TextYankPost * call s:OSC52()
endif

