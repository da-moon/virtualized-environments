function! s:justfile_tasks() abort
  let commands=split(system('just --summary --color never'),' ',1)
  let conf = {}
  for cmd in commands
    call extend(conf, {
    \ cmd : {
    \ 'command': 'just',
    \ 'args' : [cmd],
    \ 'isDetected' : 1,
    \ 'detectedName' : 'just:'
    \ }
    \ })
  endfor
  return conf
endfunction
function! before#spacevim#tasks#bootstrap()
  call SpaceVim#logger#info("[ before#spacevim#tasks#bootstrap ] function called.")
  if executable('just')
    call SpaceVim#logger#info("[ before#spacevim#tasks#bootstrap ] Just Executable detected")
    if (filereadable('Justfile') || filereadable('justfile'))
      call SpaceVim#logger#info("[ before#spacevim#tasks#bootstrap ] Project Justfile detected")
      call SpaceVim#plugins#tasks#reg_provider(function('s:justfile_tasks'))
      call SpaceVim#logger#info("[ before#spacevim#tasks#bootstrap ] Registered Justfile task provider function")
    endif
  endif
endfunction
