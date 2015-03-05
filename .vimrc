"
" sriramsh: My own vimrc file
"

" Lets vim take .vimrc file if it is present in the working directory
"
source ~/src/github/mysettings/scripts/vim_switch_scheme.vim

set exrc
set secure
syn on

" Highlight col 110 with color
"set colorcolumn=110

set number
set softtabstop=4

" Sets how many lines of history VIM has to remember
set history=250

" Set to auto read when a file is changed from the outside
set autoread

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 4 lines to the cursor - when moving vertically using j/k
set so=3

" Don't redraw while executing macros (good performance config)
set lazyredraw

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Colors
set t_Co=256

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
"Plugin 'user/L9', {'name': 'newL9'}

" Syntastic shows errors
"Plugin 'scrooloose/syntastic'
"Plugin 'bling/vim-bufferline'
"Plugin 'ervandew/supertab'
"
Plugin 'bling/vim-airline'
Plugin 'majutsushi/tagbar' " Tagbar on the right, use F8
Plugin 'Valloric/YouCompleteMe'
Plugin 'flazz/vim-colorschemes'
Plugin 'raimondi/delimitMate'
Plugin 'scrooloose/nerdtree'
Plugin 'godlygeek/tabular'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'EasyMotion'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-dispatch'
Plugin 'kien/ctrlp.vim'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'junegunn/goyo.vim'
Plugin 'fatih/vim-go'
"Plugin 'ntpeters/vim-better-whitespace'
Plugin 'christoomey/vim-tmux-navigator'
"Plugin 'bbchung/clighter'

let g:airline_powerline_fonts = 1
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" YouCompleteMe settings.
" Default config for ycm. Replace with real one later
let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
"let g:ycm_key_list_select_completion = ['<C-TAB>','<Down>']
let g:ycm_key_list_previous_completion = ['<C-S-TAB>','<Up>']

let g:ycm_register_as_syntastic_checker = 1
let g:Show_diagnostics_ui = 0

let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_always_populate_location_list = 0

let g:ycm_complete_in_strings = 1
"=====================
"let g:SuperTabDefaultCompletionType = '<C-Tab>'

" Ultisnips settings
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsExpandTrigger="<s-tab>"
let g:UltiSnipsJumpForwardTrigger="<c-i>"
let g:UltiSnipsJumpBackwardTrigger="<s-c-tab>"

"let g:ycm_key_list_select_completion=[]
"let g:ycm_key_list_previous_completion=[]

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

if has('cscope')
  set cscopetag cscopeverbose

  " if has('quickfix')
   "  set cscopequickfix=s-,c-,d-,i-,t-,e-
  " endif

  cnoreabbrev csa cs add
  cnoreabbrev csf cs find f
  cnoreabbrev csk cs kill
  cnoreabbrev csr cs reset
  cnoreabbrev css cs find s
  cnoreabbrev csh cs help
  cnoreabbrev csg cs find g
  cnoreabbrev cse cs find e
  cnoreabbrev csi cs find i
  cnoreabbrev cst cs find t

"  command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src

  "if filereadable("~/cscope/usrinclude/cscope.out")
  "Ugly hack to get around having to press enter

" load the cscope db
  set csto=0
  set cst
  set nocsverb
  cs add ~/cscope/usrinclude/cscope.out
" add any database in current directory
  if filereadable("cscope.out")
	cs add cscope.out
	" else add database pointed to by environment
  elseif $CSCOPE_DB != ""
	cs add $CSCOPE_DB
  endif
  set csverb
  set cscopeverbose
endif

"----cscope end
" System default for mappings is now the "," character
let mapleader = ","
"let mapleader = " "

nmap <Space><Space> :
nmap <Space>w :w
nmap <Space>w<Space> :w<CR>
nmap <Space>q :q<CR>
nmap <Space>q<Space> :q!

"let g:ctrlp_map = '<c-p>'
"let g:ctrlp_cmd = 'CtrlP'

" Build the cscope database in the directory
nmap <F10> :!find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' -o -iname '*.cs' > cscope.files<CR>
  \:!cscope -b -i cscope.files -f cscope.out<CR>
  \:cs reset<CR>

    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls

nmap `s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap ,s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <Space>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap `g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap ,g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <Space>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap `c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap ,c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <Space>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap `t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap ,t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <Space>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap `e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap ,e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <Space>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap `f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap ,f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <Space>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap `i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap ,i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <Space>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap `d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap ,d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <Space>d :cs find d <C-R>=expand("<cword>")<CR><CR>

" EasyMotion - Remap movement to ,w
nmap ,w H,,w

" Vertical split
nmap `vs :vert cs find s <C-R>=expand("<cword>")<CR><CR>
nmap `vg :vert cs find g <C-R>=expand("<cword>")<CR><CR>
nmap `vc :vert cs find c <C-R>=expand("<cword>")<CR><CR>
nmap `vt :vert cs find t <C-R>=expand("<cword>")<CR><CR>
nmap `ve :vert cs find e <C-R>=expand("<cword>")<CR><CR>
nmap `vf :vert cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap `vi :vert cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap `vd :vert cs find d <C-R>=expand("<cword>")<CR><CR>

" Horizontal Split
nmap `hs :scs find s <C-R>=expand("<cword>")<CR><CR>
nmap `hg :scs find g <C-R>=expand("<cword>")<CR><CR>
nmap `hc :scs find c <C-R>=expand("<cword>")<CR><CR>
nmap `ht :scs find t <C-R>=expand("<cword>")<CR><CR>
nmap `he :scs find e <C-R>=expand("<cword>")<CR><CR>
nmap `hf :scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap `hi :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap `hd :scs find d <C-R>=expand("<cword>")<CR><CR>

" Find all files including this file
nmap ;i :cs find i <C-R>=expand("%:t")<CR><CR>

" Plugin Configurations
set laststatus=2

" NERDTree Plugin configs
map <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
nmap <F8> :TagbarToggle<CR>

if has('gui_running')
    set background=light
else
    set background=dark
endif

"colorscheme summerfruit256
"colorscheme solarized
colorscheme molokai

" Shift+Tab goes across windows
:map <S-Tab> w

" Window movements across
map <C-l> <C-W>l
map <C-h> <C-W>h
map <C-j> <C-W>j
map <C-k> <C-W>k

" CtrlP commands
map <C-f> :CtrlP<CR>
map <C-b> :CtrlPMRU<CR>
map <Space>b :CtrlPMRU<CR>

" Goyo Commands
map <C-g> :Goyo<CR>

" Ignore case when searching
set ignorecase
" Understands case sensitivity when using upper case
set smartcase

" Make the 'cw' and like commands put a $ at the end instead of just deleting
" the text and replacing it
set cpoptions=ces$

" Enable search highlighting
set hlsearch

" Incrementally match the search
set incsearch

" Types of files to ignore when autocompleting things
set wildignore+=*.o,*.class,*.git,*.svn

" Turn off that stupid highlight search
nmap <silent> ,n :nohls<CR>

"NERD Tree - Dont display these types of files
let NERDTreeIgnore=[ '\.ncb$', '\.suo$', '\.vcproj\.RIMNET', '\.obj$',
                   \ '\.ilk$', '^BuildLog.htm$', '\.pdb$', '\.idb$',
                   \ '\.embed\.manifest$', '\.embed\.manifest.res$',
                   \ '\.intermediate\.manifest$', '^mt.dep$' ]


" Fix spelling mistakes
iab Acheive    Achieve
iab acheive    achieve
iab Alos       Also
iab alos       also
iab Aslo       Also
iab aslo       also
iab Becuase    Because
iab becuase    because
iab Bianries   Binaries
iab bianries   binaries
iab Bianry     Binary
iab bianry     binary
iab Charcter   Character
iab charcter   character
iab Charcters  Characters
iab charcters  characters
iab Exmaple    Example
iab exmaple    example
iab Exmaples   Examples
iab exmaples   examples
iab Fone       Phone
iab fone       phone
iab Lifecycle  Life-cycle
iab lifecycle  life-cycle
iab Lifecycles Life-cycles
iab lifecycles life-cycles
iab Seperate   Separate
iab seperate   separate
iab Seureth    Suereth
iab seureth    suereth
iab Shoudl     Should
iab shoudl     should
iab Taht       That
iab taht       that
iab Teh        The
iab teh        the


" Pasting can mess with your indentation, this toggles it on and off
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode


" CLANG auto-format
map <C-\> :pyf ~/bin/clang-format.py<cr>
"imap <C-I> <c-o>:pyf ~/bin/clang-format.py<cr>
"

" Make command
"map <F12> :make|cw<CR>
map <F12> : Make <CR> 
map <S-F12> : Make <CR> <c-j> /error: <CR>
set makeprg=make\ -C\ ~/src/WindowsFabric/src/build

" Eclim tags
map ,,g :CSearch <cr>

" Quick fix window max height
au FileType qf call AdjustWindowHeight(3, 15)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction
