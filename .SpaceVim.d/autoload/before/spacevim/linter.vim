" custom linter

function! before#spacevim#linter#vim()
  call SpaceVim#logger#info("[ before#spacevim#linter#vim ] function called")
  if executable('vimlparser')
    call SpaceVim#logger#info("[ before#spacevim#linter#vim ] vimlparser Executable detected")
    command! LintVimLParser :silent cexpr system('vimlparser ' . expand('%') . ' > /dev/null')
    augroup lint-vimlparser
      autocmd!
      autocmd BufWritePost *.vim LintVimLParser
    augroup END
  endif
endfunction
function! before#spacevim#linter#bootstrap()
  call SpaceVim#logger#info("[ before#spacevim#linter#bootstrap ] function called.")
  call before#spacevim#linter#vim()
endfunction
