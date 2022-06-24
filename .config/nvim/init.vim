" --- Plugins (Current Plugin Manager: vim-plug) ---

call plug#begin()

Plug 'scrooloose/nerdcommenter' " quickly comment out lines of code with <leader><cc> or <leader><cs> (use <leader><cu> to undo)
Plug 'neoclide/coc.nvim', {'branch': 'release'} " coc autocomplete engine
Plug 'jiangmiao/auto-pairs' " autocompletes () {} and []
Plug 'easymotion/vim-easymotion' " easy motion navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " see below
Plug 'junegunn/fzf.vim' " enables fzf search within vim with <CTRL-p>
Plug 'preservim/nerdtree' " file tree access with <CTRL-n>
Plug 'mattn/emmet-vim' " emmet.vim for web dev stuff
Plug 'joshdick/onedark.vim' " onedark colorscheme
Plug 'Luxed/ayu-vim' " ayu theme
Plug 'tiagovla/tokyodark.nvim' " tokyodark theme
Plug 'itchyny/lightline.vim' " lightline

call plug#end()

" --- Commands ---

" visual settings
syntax on " enables syntax highlighting
set background=dark
set number relativenumber " enables hybrid line numbers (mix of relative + absolute)
set nowrap " turns off line wrapping
set ruler " displays the line and column number in bottom right

" onedark
" colorscheme onedark

" ayu
" let g:ayucolor="mirage"
" let g:ayucolor="dark"
" colorscheme ayu

" tokyodark
let g:tokyodark_transparent_background = 0
let g:tokyodark_enable_italic_comment = 1
let g:tokyodark_enable_italic = 1
let g:tokyodark_color_gamma = "1.0"
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

" searching
set incsearch " enables incremental searching
set hlsearch " highlights search results
set smartcase " ignores case until I enter uppercase letter

" indent settings
set autoindent " vim does its best to indent for me
filetype plugin indent on " enables smart indenting based on the type of file

" plugin settings
let g:ycm_show_diagnostics_ui=0 " turns off YCM linter
set completeopt-=preview " turns off the YCM preview window

" remap easymotion settings -> default is <leader><leader><motion>, this makes it <leader><motion>
map <leader> <Plug>(easymotion-prefix)

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
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
