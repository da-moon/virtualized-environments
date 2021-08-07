function! init#before() abort
  call SpaceVim#logger#info("[ init#before ] function called")
  call before#spacevim#plugins#bootstrap()
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
  call after#coc#install#bootstrap()
  set showcmd
  nnoremap <silent> [Window]a :cclose<CR>:lclose<CR>
endfunction
