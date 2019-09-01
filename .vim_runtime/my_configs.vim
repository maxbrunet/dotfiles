set rtp+=/home/maxime/.fzf
map <leader>ff :FZF<CR>
colorscheme gruvbox
let g:ycm_python_binary_path = 'python'
let g:ycm_filetype_blacklist = {
      \ 'python': 1,
      \ 'tagbar': 1,
      \ 'qf': 1,
      \ 'notes': 1,
      \ 'markdown': 1,
      \ 'unite': 1,
      \ 'text': 1,
      \ 'vimwiki': 1,
      \ 'pandoc': 1,
      \ 'infolog': 1,
      \ 'mail': 1
      \}
let g:ale_completion_enabled = 1
let g:ale_linters={
\ 'go': ['gotlint', 'govet'],
\ 'python': ['flake8', 'pyls'],
\ }
let g:ale_fixers={
\ 'go': ['goimports'],
\ 'python': ['isort', 'black'],
\ }
set completeopt=menu,menuone,preview,noselect,noinsert
highlight ColorColumn ctermbg=red guibg=red
call matchadd('ColorColumn', '\%81v', 100)
set spell spelllang=en
