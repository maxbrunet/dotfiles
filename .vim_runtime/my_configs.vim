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
"" Disable Go and Python completion, we use ALE for that
"" ALE can act as a source for Deoplete, but some information from LSP
"" seems to get lost compared to direct usage from ALE
autocmd FileType {go,python}
\ call deoplete#custom#buffer_option('auto_complete', v:false)

" ALE
let g:ale_completion_enabled = 1
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
