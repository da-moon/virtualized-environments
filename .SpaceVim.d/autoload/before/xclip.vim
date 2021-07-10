function! XClipYank()
	let l:data = join(getline(a:firstline, a:lastline), "\n")
	call system('xclip -i -selection clipboard', l:data)
endfunction

function! XClipPaste()
	read !xclip -o -selection clipboard
endfunction

function! XClipGet()
	let @@ = system('xclip -o -selection clipboard')
endfunction

function! XClipPut()
	call system('xclip -i -selection clipboard', @@)
endfunction

command! -range -nargs=0 XClipYank <line1>,<line2>call XClipYank()
command! -nargs=0 XClipPaste call XClipPaste()
command! -nargs=0 XClipGet call XClipGet()
command! -nargs=0 XClipPut call XClipPut()


function! before#xclip#bootstrap()
  call SpaceVim#logger#info("[ before#xclip#bootstrap ] function called.")
	" call SpaceVim#logger#info("[ before#xclip#bootstrap ] binding xclip group to 'X'.")
	" call SpaceVim#custom#SPCGroupName(['X'], '+xclip')
	" call SpaceVim#custom#SPC('nore', ['X', 'c'], 'XClipPut', 'Copy selected part to clipboard',1)
	" call SpaceVim#custom#SPC('nore', ['X', 'p'], 'XClipPaste', 'Copy selected part to clipboard',1)
	" call SpaceVim#custom#SPC('nore', ['X', 'c'], 'w !xclip -i -sel c', 'Copy selected part to clipboard',1)
	" call SpaceVim#custom#SPC('nore', ['X', 'C'], '%w !xclip -i -sel c', 'Copy whole file to clipboard',1)
	" call SpaceVim#custom#SPC('nore', ['X', 'p'], 'r !xclip -o -sel -c', 'Paste from clipboard',1)
endfunction
