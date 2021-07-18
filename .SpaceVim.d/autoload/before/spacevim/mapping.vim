function! before#spacevim#mapping#search() abort
  call SpaceVim#logger#info("[ before#spacevim#mapping#search ] function called.")
  call SpaceVim#logger#info("[ before#spacevim#mapping#bootstrap ] enabling forward search in visual block mode with '*'")
  vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
  call SpaceVim#logger#info("[ before#spacevim#mapping#bootstrap ] enabling backward search in visual block mode with '#'")
  vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
  call SpaceVim#logger#info("[ before#spacevim#mapping#bootstrap ] enabling easy search and replace in visual mode with ctrl+r")
  vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

endfunction
function! before#spacevim#mapping#bootstrap() abort
  call SpaceVim#logger#info("[ before#spacevim#mapping#bootstrap ] function called.")
  call before#spacevim#mapping#search()
endfunction
