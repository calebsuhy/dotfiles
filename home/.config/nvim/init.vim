" --- Plugins (Current Plugin Manager: vim-plug) ---

call plug#begin()

Plug 'scrooloose/nerdcommenter' " quickly comment out lines of code with <leader><cc> or <leader><cs> (use <leader><cu> to undo)
Plug 'neoclide/coc.nvim', {'branch': 'release'} " coc autocomplete engine
Plug 'jiangmiao/auto-pairs' " autocompletes () {} and []
Plug 'phaazon/hop.nvim' " better easymotion
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " see below
Plug 'junegunn/fzf.vim' " enables fzf search within vim with <CTRL-p>
Plug 'preservim/nerdtree' " file tree access with <CTRL-n>
Plug 'tiagovla/tokyodark.nvim' " tokyodark theme
Plug 'itchyny/lightline.vim' " lightline
Plug 'lervag/vimtex'
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

call plug#end()

lua require('hop').setup()

" --- Commands ---

" visual settings
syntax on " enables syntax highlighting
set background=dark
set number relativenumber " enables hybrid line numbers (mix of relative + absolute)
set nowrap " turns off line wrapping
set ruler " displays the line and column number in bottom right
set colorcolumn=75 " creats a column at column 81

" tokyodark
" let g:tokyodark_transparent_background = 1
let g:tokyodark_enable_italic_comment = 1
let g:tokyodark_enable_italic = 1
let g:tokyodark_color_gamma = "1.0"
" Configure the theme options using Lua
lua << EOF
require('tokyodark').setup({
    transparent_background = true, -- Enable transparent background
})
EOF
colorscheme tokyodark

" status line
set laststatus=2
set noshowmode 
let g:lightline = {'colorscheme': 'one'}

" remap leader key
let mapleader="," " remaps leader key from \ to ,

" press <leader><space> to get rid of highlights post-search
nnoremap <leader><space> :nohlsearch<CR>

" tab settings
set tabstop=4 " vim reads tab characters as 4 columns
set softtabstop=4 " pressing <TAB> inserts 4 columns
set shiftwidth=4 " << and >> commands shift lines 4 columns to the left and right respectively
set expandtab " tabs are turned into the equivalent ammount of spaces
autocmd FileType html setlocal shiftwidth=2 tabstop=2 wrap linebreak " changes settings for html

" ngspice netlists (.cir/.ckt) use the spice filetype, like .sp and .spice already do
autocmd BufRead,BufNewFile *.cir,*.ckt setfiletype spice
let g:NERDCustomDelimiters = { 'spice': { 'left': '*' } } " comment spice lines with * instead of $

" searching
set incsearch " enables incremental searching
set hlsearch " highlights search results
set smartcase " ignores case until I enter uppercase letter

" indent settings
set autoindent " vim does its best to indent for me
filetype plugin indent on " enables smart indenting based on the type of file

" hop.nvim keybindings
nnoremap <leader>f :HopWord<CR>

" enable normal backspacking
set backspace=indent,eol,start

" set vim.swp file storage directory
set directory^=$HOME/.vim/swapfiles//

" toggle nerd tree with <CTRL-n>
map <C-n> :NERDTreeToggle<CR>

" remap :Files fzf command to <CTRL-p>
nnoremap <C-p> :Files<Cr>

" true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" tab completion for coc.vim
" use <tab> for trigger completion and navigate to the next complete item
" <C-y> accepts an item (and expands it if it's a snippet)
" inside a snippet, <tab>/<S-tab> jump to the next/previous field
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<S-tab>'
