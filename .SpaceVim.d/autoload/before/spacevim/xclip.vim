

function! before#spacevim#xclip#yank()
  call SpaceVim#logger#info("[ before#spacevim#xclip#yank ] function called.")
  function! XClipYank()
    let l:data = join(getline(a:firstline, a:lastline), "\n")
    call system('xclip -i -selection clipboard', l:data)
  endfunction
  command! -range -nargs=0 XClipYank <line1>,<line2>call XClipYank()
endfunction

function! before#spacevim#xclip#paste()
  call SpaceVim#logger#info("[ before#spacevim#xclip#paste ] function called.")
  function! XClipPaste()
    read !xclip -o -selection clipboard
  endfunction
  command! -nargs=0 XClipPaste call XClipPaste()
	call SpaceVim#custom#SPC('nore', ['X', 'p'], 'XClipPaste', 'Copy selected part to clipboard',1)
endfunction

function! before#spacevim#xclip#get()
  call SpaceVim#logger#info("[ before#spacevim#xclip#get ] function called.")
  function! XClipGet()
    let @@ = system('xclip -o -selection clipboard')
  endfunction
  command! -nargs=0 XClipGet call XClipGet()
endfunction

function! before#spacevim#xclip#put()
  call SpaceVim#logger#info("[ before#spacevim#xclip#put ] function called.")
  function! XClipPut()
    call system('xclip -i -selection clipboard', @@)
  endfunction
  command! -nargs=0 XClipPut call XClipPut()
	call SpaceVim#custom#SPC('nore', ['X', 'c'], 'XClipPut', 'Copy selected part to clipboard',1)
endfunction



function! before#spacevim#xclip#bootstrap()
  if executable('xclip')
    call SpaceVim#logger#info("[ before#spacevim#xclip#bootstrap ] function called.")
    call SpaceVim#logger#info("[ before#spacevim#xclip#bootstrap ] binding xclip group to 'X'.")
    call SpaceVim#custom#SPCGroupName(['X'], '+xclip')
    call SpaceVim#custom#SPC('nore', ['X', 'c'], 'w !xclip -i -sel c', 'Copy selected part to clipboard',1)
    call SpaceVim#custom#SPC('nore', ['X', 'C'], '%w !xclip -i -sel c', 'Copy whole file to clipboard',1)
    call SpaceVim#custom#SPC('nore', ['X', 'p'], 'r !xclip -o -sel -c', 'Paste from clipboard',1)
    call before#spacevim#xclip#yank()
    call before#spacevim#xclip#paste()
    call before#spacevim#xclip#get()
    call before#spacevim#xclip#put()
  endif
endfunction
