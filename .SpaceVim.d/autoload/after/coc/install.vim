function! after#coc#install#bootstrap()
  call SpaceVim#logger#info("[ after#coc#install#bootstrap ] function called.")
  for extension in g:coc_extensions
    call SpaceVim#logger#info("[ after#coc#install#bootstrap ] installing [ " . extension . " ] coc extension")
    call coc#add_extension(extension)
  endfor
  call coc#config('coc.preferences', g:coc_preferences)
endfunction
