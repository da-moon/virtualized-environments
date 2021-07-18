function! before#spacevim#generic#variables()
  call SpaceVim#logger#info("[ before#spacevim#generic#variables ] function called.")
  let g:spacevim_enable_debug = 1
  let g:spacevim_realtime_leader_guide = 1
  let g:spacevim_enable_tabline_filetype_icon = 1
  let g:spacevim_enable_statusline_display_mode = 0
  let g:spacevim_enable_os_fileformat_icon = 1
  let g:spacevim_buffer_index_type = 1
  let g:spacevim_todo_labels = [
    \'FIXME',
    \'[FIXME]',
    \'[ FIXME ]',
    \'QUESTION',
    \'[QUESTION]',
    \'[ QUESTION ]',
    \'TODO',
    \'[TODO]',
    \'[ TODO ]',
    \'IDEA',
    \'[IDEA]',
    \'[ IDEA ]',
  \]
endfunction
function! before#spacevim#generic#tabsizes() abort
  call SpaceVim#logger#info("[ before#spacevim#generic#tabsizes ] function called.")
  call SpaceVim#logger#info("[ before#spacevim#generic#tabsizes ] setting .go file tab sizes")
  au BufNewFile,BufRead *.go setlocal expandtab tabstop=4 shiftwidth=4
  call SpaceVim#logger#info("[ before#spacevim#generic#tabsizes ] setting .vim file tab sizes")
  au BufNewFile,BufRead *.vim setlocal expandtab tabstop=4 shiftwidth=2
  call SpaceVim#logger#info("[ before#spacevim#generic#tabsizes ] setting yaml file tab sizes")
  au BufNewFile,BufRead *.yml,*.yaml setlocal expandtab tabstop=4 shiftwidth=2
endfunction

function! before#spacevim#generic#bootstrap()
  call SpaceVim#logger#info("[ before#spacevim#generic#bootstrap ] function called.")
  call before#spacevim#generic#variables()
   if &term =~ 'screen'
    set term=xterm-256color
  endif
  call SpaceVim#logger#info("[ before#spacevim#generic#bootstrap ] Default to case insensitive searches.")
  set ignorecase
  set smartcase
  call SpaceVim#logger#info("[ before#spacevim#generic#bootstrap ] Keep lines above or below the cursor at all times.")
  set scrolloff=7
  set colorcolumn=80,125
  call SpaceVim#logger#info("[ before#spacevim#generic#bootstrap ] Wrap around lines in insert mode.")
  set whichwrap+=<,>,h,l,[,]
  call SpaceVim#logger#info("[ before#spacevim#generic#bootstrap ] Raise cmdheight so echodoc can display function parameters.")
  set cmdheight=2
  call SpaceVim#logger#info("[ before#spacevim#generic#bootstrap ] Decrease idle time.")
  set updatetime=350
endfunction
