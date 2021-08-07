
" \ ['hashivim/vim-hashicorp-tools'],
function! before#spacevim#plugins#bootstrap()
  call SpaceVim#logger#info("[ before#spacevim#plugins#bootstrap ] function called.")
  let g:spacevim_custom_plugins = [
    \ ['jvirtanen/vim-hcl',{ 'on_ft' : 'hcl'}],
    \ ['neoclide/coc.nvim'],
    \ ['PhilRunninger/nerdtree-visual-selection'],
    \ ['mg979/vim-visual-multi'],
    \ ['will133/vim-dirdiff'],
    \ ['tarekbecker/vim-yaml-formatter'],
    \ ['machakann/vim-highlightedyank'],
    \ ['sainnhe/sonokai'],
    \ ['dracula/vim'],
    \ ['sheerun/vim-polyglot'],
    \ ['phanviet/vim-monokai-pro'],
    \ ['cormacrelf/vim-colors-github'],
    \ ]
  if executable('shfmt')
    call SpaceVim#logger#info("[ before#spacevim#plugins#bootstrap ] 'shfmt' binary detected. Adding associated vim plugin")
    call add(g:spacevim_custom_plugins,['z0mbix/vim-shfmt',{ 'on_ft': 'sh' }])
  end
  if executable('shfmt')
    call SpaceVim#logger#info("[ before#spacevim#plugins#bootstrap ] 'just' binary detected. Adding associated vim plugin")
    call add(g:spacevim_custom_plugins,['vmchale/just-vim',{ 'on_ft': 'justfile' }])
  end
endfunction
