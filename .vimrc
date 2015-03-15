" This is my VIM settings that I like. I use it for C++ and sometimes Golang.
" Change and use as you see fit. No warranties.
" - sriramsh
"
" Tips:
" putty - If using putty, send putty-256color as terminfo, 
" color scheme - molokai when tired, summerfruit256 on putty and solarized(light) 
"   when showing off ;-)
"
" Install:
"   cscope - tags, searching the code base
"   clang(for c++ autocomplete and compile YCM with this option)
"
" WARNING: You will be sorely disappointed with VIM if you don't use a terminal
" that provides atleast 256 colors. I use Terminator(set terminal color palette
" to solarized on linux and if am forced to putty at gunpoint, I set it's terminfo
" to putty-256color.  Details here:
" http://vim.wikia.com/wiki/256_colors_setup_for_console_Vim
"
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" These are some of my custom key mappings that I use most
"
" F2  - Cut n Pasting code into vim window messes indentation, F2 toggles paste
"       mode
" F8  - Enable/Disable tagbar on the right. Shows classes and file organization
" F10 - Rebuild cscope tags in the local directory
"
" F12 - Compile using the custom command and open file result in quickfix 
"
" ctrl+b - Open MRU files and search by typing the name
" ctrl+f - Open list of files in local directory and search
" ctrl+n - Open NERDTree
"
" shift+tab - Go across windows
"
" Navigating around files and symbols.
" ,g - go to global definition of symbol under cursor
" ,s - find all instances of the symbal under cursor
" ,t - find text under cursor
" Lot more, see mappings below
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set exrc
set secure
syn on

" Take .vimrc file if it is present in the working directory
" Used for giving custom Make commands
"if filereadable(".vimrc")
"    source .vimrc
"endif

" Switch color schemes on shift+F8
"if filereadable("~/src/github/mysettings/scripts/vim_switch_scheme.vim")
    "source ~/src/github/mysettings/scripts/vim_switch_scheme.vim
"endif

" Syntax on, neovim seems to need it
syntax on

" Highlight col 110 with color. To not type beyond it.
"set colorcolumn=110

" switch on line numbers on the left side
set number

" how many lines of history VIM has to remember
set history=250

" auto read when a file is changed from the outside
set autoread

" Set 3 lines to the cursor - when moving vertically using j/k
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
set softtabstop=4
set tabstop=4

" Colors
set t_Co=256

" Linebreak on 500 characters
set lbr
set tw=500

"Auto indent
set ai 
"Smart indent
set si 
"Wrap lines
set wrap 
"
set nocompatible              " be iMproved, required
filetype off                  " required

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins needed, install with PluginInstall the first time
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'airblade/vim-gitgutter' " Shows changed lines in leftmost column
Plugin 'tpope/vim-fugitive'
Plugin 'L9'

" Syntastic shows errors
Plugin 'scrooloose/syntastic'
"Plugin 'ervandew/supertab'

Plugin 'bling/vim-airline'
Plugin 'majutsushi/tagbar' " Tagbar on the right, use F8
Plugin 'Valloric/YouCompleteMe' " Autocomplete et al
Plugin 'flazz/vim-colorschemes' " Installs almost all color schemes
Plugin 'raimondi/delimitMate'
Plugin 'scrooloose/nerdtree' " Navigate the file system
Plugin 'Xuyuanp/nerdtree-git-plugin' " Git hints in nerd tree
Plugin 'godlygeek/tabular'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'EasyMotion' 
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-dispatch'
Plugin 'kien/ctrlp.vim'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'junegunn/goyo.vim'
Plugin 'fatih/vim-go' " Golang plugins
Plugin 'jelera/vim-javascript-syntax'
Plugin 'marijnh/tern_for_vim'
"Plugin 'ntpeters/vim-better-whitespace'
"Plugin 'christoomey/vim-tmux-navigator'
" Javascript
"Plugin 'pangloss/vim-javascript'
"Plugin 'bbchung/clighter'

" To get the > font with color below. check online to get this font
let g:airline_powerline_fonts = 1
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Installing and updating plugins
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

"NERD Tree - Dont display these types of files
let NERDTreeIgnore=[ '\.ncb$', '\.suo$', '\.vcproj\.RIMNET', '\.obj$',
                   \ '\.ilk$', '^BuildLog.htm$', '\.pdb$', '\.idb$',
                   \ '\.embed\.manifest$', '\.embed\.manifest.res$',
                   \ '\.intermediate\.manifest$', '^mt.dep$' ]

" System default for mappings is now the "," character
let mapleader = ","

" Saving left-pinky from shift
nmap <Space><Space> :
nmap <Space>w :w
nmap <Space>w<Space> :w<CR>
nmap <Space>q :q<CR>
nmap <Space>q<Space> :q!

"let g:ctrlp_map = '<c-p>'
"let g:ctrlp_cmd = 'CtrlP'
"
" Pasting can mess with your indentation, this toggles it on and off
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode


" EasyMotion - Remap movement to ,w
nmap ,w H,,w

" Syntax highlighting and color schemes
if has('gui_running')
    set background=light
else
    set background=dark
endif

"colorscheme summerfruit256 " Pretty good when using putty configured for 256 colors
"colorscheme solarized
colo molokai

" cscope to browse through files
if has('cscope')
    set cscopetag cscopeverbose

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

    " load the cscope db
    set csto=0
    set cst
    set nocsverb

    " get the headers to get to definitions for libraries
    if filereadable("~/cscope/usrinclude/cscope.out")
        cs add ~/cscope/usrinclude/cscope.out
    endif

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

" Build the cscope database in the directory on F10
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

" Searching
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

" Turn off that annoying highlight search that never goes away
nmap <silent> ,n :nohls<CR>

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

" CLANG auto-format
map <C-\> :pyf ~/bin/clang-format.py<cr>
"imap <C-I> <c-o>:pyf ~/bin/clang-format.py<cr>

" Make command. Change the build directory as per your need.
" Preferably set in a .vimrc locally
map <F12> : Make <CR> 
map <S-F12> : Make <CR> <c-j> /error: <CR>
set makeprg=make\ -C\ build

" Eclim tags. Eclim is better at getting to global definitions for C++
map ,,g :CSearch <cr>

" Quick fix window max height
au FileType qf call AdjustWindowHeight(3, 15)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction
