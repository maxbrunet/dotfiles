" github.com/amix/vimrc
set runtimepath+=~/.local/share/amix-vimrc
source ~/.local/share/amix-vimrc/vimrcs/basic.vim
source ~/.local/share/amix-vimrc/vimrcs/filetypes.vim
source ~/.local/share/amix-vimrc/vimrcs/plugins_config.vim
source ~/.local/share/amix-vimrc/vimrcs/extended.vim

" fzf
if has('mac')
  set rtp+=/usr/local/opt/fzf
endif
map <leader>ff :FZF<CR>

" Color scheme
colorscheme gruvbox
let g:lightline = {
\ 'colorscheme': 'gruvbox',
\ }

" Disable Nvim GUI cursor
set guicursor=

" pynvim, see :help provider-python
if has('mac')
  let g:python3_host_prog = '~/.pyenv/versions/neovim3/bin/python3'
else
  let g:python3_host_prog = '/usr/bin/python3'
endif

" Deoplete
"" Installation requires to be completed with :UpdateRemotePlugins
let g:deoplete#enable_at_startup = 1
"" Use ALE as completion sources for Go and Python code
call deoplete#custom#option('sources', {
\ 'go': ['ale'],
\ 'python': ['ale'],
\})

" Ale
let g:ale_linters={
\ 'go': ['golangci-lint', 'gopls'],
\ 'python': ['flake8', 'pylsp'],
\ }
let g:ale_fixers={
\ 'go': ['gofmt', 'goimports'],
\ 'python': ['isort', 'black'],
\ 'sh': ['shfmt'],
\ 'terraform': ['terraform'],
\ }
"" Google's shell style formatting
let g:ale_sh_shfmt_options='-i 2 -ci -bn'

" Highlight lines over 80 characters long
highlight ColorColumn ctermbg=red guibg=red
call matchadd('ColorColumn', '\%81v', 100)

" Spellchecking
set spell spelllang=en
