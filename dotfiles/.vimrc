" Necessary for lots of cool vim things
set nocompatible

" Support modelines in files that are open
set modeline

" Show what you are typing as a command
set showcmd

" Allow switching buffers without writing out first
set hidden

" Enable filetype detection, plugins, and syntax highlighting
filetype on
filetype plugin indent on
syntax on

" Go into paste mode to avoid e.g. autoindent
nnoremap <F3> :set paste!<CR>:set paste?<CR>

" Automatically indent new lines
set autoindent

" Uses spaces instead of tabs
set noexpandtab
set copyindent
set preserveindent
set softtabstop=0
set shiftwidth=4
set tabstop=4
set cindent
set cinoptions=(0,u0,U0

" Set grep options
set grepprg=grep\ -Inr\ --exclude-dir=.git

" Allow changing tabbing using F6 & F7

function! ChangeTabbing(newtab)
   let &shiftwidth = a:newtab
   let &softtabstop = a:newtab
   if &shiftwidth == 8
      set noexpandtab
   else
      set expandtab
   endif
   set softtabstop?
endfunction

nnoremap <F6> :call ChangeTabbing(&shiftwidth - 1)<CR>
nnoremap <F7> :call ChangeTabbing(&shiftwidth + 1)<CR>

" Use tabbing of 2 for yaml
autocmd BufRead,BufNewFile *.yaml,*.yml silent! :call ChangeTabbing(2)

" Don't care about casing when the query is all lowercase
set ignorecase
set smartcase

" Remaps kj in Insert Mode to <ESC>
inoremap kj <Esc>
inoremap kJ <Esc>

" Highlight search results
set hlsearch

" Always display a status bar
set laststatus=2

" Retrieves the number of buffers available
" This is used in the statusline after
" From http://superuser.com/questions/345520
" May delete if we don't use it in the statusline
function! NrBufs()
    let i = bufnr('$')
    let j = 0
    while i > 0
        if buflisted(i)
            let j += 1
        endif
        let i -= 1
    endwhile
    return j
endfunction

" Formatting of the status bar
" set statusline=%F%m%r%h%w%<\ {%Y}\ %=[%l,%v][%p%%][%n/%{NrBufs()}]
set statusline=%F%m%r%h%w%<\ {%Y}\ %=[%l,%v][%p%%]
"set statusline=%F%m%r%h%w%<\ {%Y}\ %=%{fugitive#statusline()}[%l,%v][%p%%]

" Start searching as we type
set incsearch

" Show relative line numbers black on grey
set number " Shows absolute line number at cursor pos
set relativenumber " Shows relative line number elsewhere
highlight LineNr ctermfg=black ctermbg=grey

" Necessary for the MiniBufExplorer extension, which shows
" line numbers if 'number' and 'relativenumber' are on.
" I've filed an issue with them (issue 102 on GitHub)
"noremap <F6> :MBEFocus<CR>:set<Space>nonumber<CR>:set<Space>norelativenumber<CR><C-W>j
let g:miniBufExplStatusLineText = "---"

" Characters to use when :set list is turned on to display hidden chars
set listchars=tab:>-,trail:~,extends:>,precedes:<

" Start with list on
set list

" Show/hide hidden characters
nnoremap <F2> :set list!<CR>:set list?<CR>

" Keep cursor within 3 lines of top or bottom line when scrolling
set scrolloff=3

" Exclude selected char in selections
"set selection=exclusive

" Show visual mode selection with green background
highlight Visual ctermbg=Green

" This clears highlighting from a previous pattern search
" (But it does NOT clear the search pattern, so 'n' would
" still keep searching!)
nnoremap <silent> <CR> :noh<CR><CR>

" This actually clears the 'last search term' register so
" the advantage is that it does not move the cursor
map <silent> <C-N> :let @/=""<CR>

" Enable mouse support for all modes
set mouse=a

" Buffer switcher
noremap <F5> :buffers<CR>:buffer<Space>
nnoremap <C-J> :bnext<CR>
nnoremap <C-K> :bprev<CR>
nnoremap <C-H> :bd<CR>

" Switch between 0, 60, 72, and 80 textwidth
function! ChangeTextWidth()
   if &textwidth == 0
      set textwidth=60
   elseif &textwidth == 60
      set textwidth=72
   elseif &textwidth == 72
      set textwidth=80
   else
      set textwidth=0
   endif
   if &textwidth == 0
      set colorcolumn=
   else
      set colorcolumn=+1
   endif
   set textwidth?
endfunction

noremap <F4> :call ChangeTextWidth()<CR>

" If we're editing code, automatically turn on the 80 width
autocmd BufNewFile,BufRead *.java,*.c,*.cpp,*.cxx,*.yaml,*.yml set textwidth=80
autocmd BufNewFile,BufRead *.py set textwidth=79

" File types that don't necessarily have an extension
autocmd FileType bash,sh set textwidth=80
autocmd FileType python set textwidth=79

" Turn on coloured column (won't actually be on unless textwidth != 0)
set colorcolumn=+1

" Turn on/off highlighting of column textwidth+1
nnoremap <leader>l :set colorcolumn=+1<CR>
nnoremap <leader>L :set colorcolumn=<CR>

" Move by screen lines, not by real lines
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

" Insert new line without exiting normal mode
nnoremap <silent> <leader>o o<ESC>
nnoremap <silent> <leader>O O<ESC>

" Reselect visual block after indent/outdent
xnoremap < <gv
xnoremap > >gv

" Commands to open .vimrc and source it
command! VIMRC :e $MYVIMRC
command! SOURCE source $MYVIMRC

" Make :W analogous to :w
command! W :w

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Toggle the NERDTree
nnoremap <F8> :NERDTreeToggle<CR>

" Remember undo history
set undofile
set undodir=$HOME/.vim/undo
set undolevels=10000
set undoreload=100000

" Make backing up and swapping happen in centralized location
set backup
set backupdir=$HOME/.vim/backup//
set directory=$HOME/.vim/swap//
set writebackup

" Create dirs if they don't already exist
silent !mkdir -p $HOME/.vim/{undo,backup,swap} > /dev/null 2>&1

" Make text 60 chars wide for weekly report and markdown
autocmd BufRead,BufNewFile *.rpt set textwidth=60
autocmd BufRead,BufNewFile *.md set textwidth=60
autocmd BufRead,BufNewFile *.doc set textwidth=72

autocmd BufReadPost fugitive://* set bufhidden=delete

" For compabitily with tmux's xterm-style keys
if &term =~ '^screen'
   execute "set <xUp>=\e[1;*A"
   execute "set <xDown>=\e[1;*B"
   execute "set <xRight>=\e[1;*C"
   execute "set <xLeft>=\e[1;*D"
endif

let g:vim_markdown_folding_disabled=1

if filereadable(expand("~/.vim/autoload/pathogen.vim"))
   execute pathogen#infect()
   execute pathogen#helptags()
endif

" Allow local projects to override settings
" https://andrew.stwrt.ca/posts/project-specific-vimrc/
set exrc
set secure

" Always put a vsplit on the right of current
set splitright

" Always put a vsplit under current
" XXX: disabled because otherwise MBE goes below
"set splitbelow
