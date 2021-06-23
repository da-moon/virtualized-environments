" common vim and nvim configs
function! before#cfg#bootstrap() abort
  if &term =~ 'screen'
    set term=xterm-256color
  endif
  call SpaceVim#logger#info("[config] Default to case insensitive searches.")
  set ignorecase
  set smartcase
  call SpaceVim#logger#info("[config] Keep lines above or below the cursor at all times.")
  set scrolloff=7
  set colorcolumn=80,125
  call SpaceVim#logger#info("[config] Wrap around lines in insert mode.")
  set whichwrap+=<,>,h,l,[,]
  call SpaceVim#logger#info("[config] Raise cmdheight so echodoc can display function parameters.")
  set cmdheight=2
  call SpaceVim#logger#info("[config] Decrease idle time.")
  set updatetime=350
  call before#cfg#mapping()
  call before#cfg#tabsizes()
endfunction

function! before#cfg#mapping() abort
  " https://stackoverflow.com/a/676619
  call SpaceVim#logger#info("[config] enabling forward search in visual block mode with '*'")
  vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
  call SpaceVim#logger#info("[config] enabling backward search in visual block mode with '#'")
  vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
  call SpaceVim#logger#info("[config] enabling easy search and replace in visual mode with ctrl+r")
  vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>
endfunction
function! before#cfg#tabsizes() abort
  call SpaceVim#logger#info("[config] setting .go file tab sizes")
  au BufNewFile,BufRead *.go setlocal expandtab tabstop=4 shiftwidth=4
endfunction
