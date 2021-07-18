let s:themes= [
\ "monokai_pro",
\ "gruvbox",
\ "solarized",
\ "sonokai",
\ "dracula",
\]
function! before#themes#bootstrap()
  call SpaceVim#logger#info("[ before#themes#bootstrap ] function called.")
  let l:remainder = localtime() % len(s:themes)
  let l:selected=s:themes[l:remainder]
  call SpaceVim#logger#info("[ config ] selected [ ".l:selected." ] theme randomly.")
  let g:spacevim_colorscheme=l:selected
  " call before#themes#github()
endfunction
function! before#themes#github()
  call SpaceVim#logger#info("[ before#themes#github ] function called.")
  let g:spacevim_colorscheme="github"
  let g:airline_theme = "github"
  let g:lightline = { 'colorscheme': 'github' }
  let g:spacevim_colorscheme_bg="light"
endfunction
