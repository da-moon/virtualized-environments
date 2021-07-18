let g:spacevim_custom_plugins = [
  \ ['neoclide/coc.nvim'],
  \ ['vmchale/just-vim'],
  \ ['PhilRunninger/nerdtree-visual-selection'],
  \ ['mg979/vim-visual-multi'],
  \ ['hashivim/vim-hashicorp-tools'],
  \ ['will133/vim-dirdiff'],
  \ ['tarekbecker/vim-yaml-formatter'],
  \ ['machakann/vim-highlightedyank'],
  \ ['sainnhe/sonokai'],
  \ ['dracula/vim'],
  \ ['sheerun/vim-polyglot'],
  \ ['phanviet/vim-monokai-pro'],
  \ ['cormacrelf/vim-colors-github'],
  \ ]


function! init#before() abort
  call SpaceVim#logger#info("[ init#before ] function called")
  call before#spacevim#generic#bootstrap()
  call before#spacevim#nvim#bootstrap()
  call before#spacevim#mapping#bootstrap()
  call before#spacevim#tasks#bootstrap()
  call before#spacevim#linter#bootstrap()
  call before#spacevim#xclip#bootstrap()
  call before#themes#bootstrap()
  call before#coc#common#bootstrap()
  call before#coc#list#bootstrap()
  call before#coc#json#bootstrap()
endfunction

function! init#after() abort
  call SpaceVim#logger#info("[ init#after ] function called")
  set showcmd
  nnoremap <silent> [Window]a :cclose<CR>:lclose<CR>
endfunction
