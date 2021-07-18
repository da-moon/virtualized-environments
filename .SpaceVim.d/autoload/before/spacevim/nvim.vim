function! before#spacevim#nvim#bootstrap() abort
  call SpaceVim#logger#info("[ before#spacevim#nvim#bootstrap ] function called.")
  if has('nvim')
    call SpaceVim#logger#info("[ before#spacevim#nvim#bootstrap ] display result of incremental commands (ex. :%s/pat1/pat2/g) ")
    set inccommand=split
    call SpaceVim#logger#info("[ before#spacevim#nvim#bootstrap ] enter terminal buffer in Insert instead of Normal mode")
    autocmd TermOpen term://* startinsert
  endif
endfunction
