function! before#coc#json#bootstrap()
  call SpaceVim#logger#info("[ before#coc#json ] bootstrap function called.")
  call before#coc#json#core()
  call before#coc#json#format()
endfunction
function! before#coc#json#core()
  call SpaceVim#logger#info("[ before#coc#json ] setting coc-json key bindings.")
  call SpaceVim#custom#SPCGroupName(['C','j'], '+Coc-json')
endfunction
function! before#coc#json#format()
  call SpaceVim#logger#info("[ before#coc#json ] setting coc-format-json key bindings.")
  call SpaceVim#custom#SPC('nore', ['C', 'j','f'], 'CocCommand formatJson --quote-as-needed --indent=2 --quote="', 'Formats whole JSON file', 1)
  call SpaceVim#custom#SPC('nore', ['C', 'j','v'], 'CocCommand formatJson.selected --quote-as-needed --indent=2 --quote="', 'Format selected text', 1)
endfunction
