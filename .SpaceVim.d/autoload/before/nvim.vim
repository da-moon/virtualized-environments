function! before#nvim#bootstrap() abort
  call SpaceVim#logger#info("[config] display result of incremental commands (ex. :%s/pat1/pat2/g) ") 
  set inccommand=split 
  call SpaceVim#logger#info("[config] enter terminal buffer in Insert instead of Normal mode")
  autocmd TermOpen term://* startinsert             
endfunction
