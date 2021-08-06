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
function! before#spacevim#linter#golang()
  call SpaceVim#logger#info("[ before#spacevim#linter#golang ] function called")
  if executable('golangci-lint')
    call SpaceVim#logger#info("[ before#spacevim#linter#vim ] golangci-lint Executable detected")
    let s:golangci_config = SpaceVim#plugins#projectmanager#current_root(). '.golangci.yml'
    if (filereadable(s:golangci_config))
      let g:go_metalinter_command = "golangci-lint"
    endif
  endif
endfunction

  call SpaceVim#logger#info("[ plugin#go ] configuring golangci-lint command")
  " let g:go_metalinter_command='golangci-lint'
  " let g:go_metalinter_command='golangci-lint run --config ' . s:golangci_config

function! before#spacevim#linter#bootstrap()
  call SpaceVim#logger#info("[ before#spacevim#linter#bootstrap ] function called.")
  call before#spacevim#linter#vim()
  call before#spacevim#linter#golang()
endfunction
