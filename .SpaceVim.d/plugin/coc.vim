" https://github.com/SpaceVim/SpaceVim/issues/2564#issuecomment-462086849
" https://github.com/Gabirel/dotfiles/blob/master/.SpaceVim.d/init.vim
let g:coc_start_at_startup    = 1
let g:coc_force_debug = 1

let g:coc_disable_startup_warning = 1
let g:UltiSnipsExpandTrigger = "<nop>"

" If coc-explorer is the only buffer then close that too
autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif
" Coc: Use `:Format` to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')
" Coc: Use `:Refactor` for refactoring window for current symbos
command! -nargs=0 Refactor :call CocActionAsync('refactor')
" Coc: Use `:Fold` to fold current buffer
command! -nargs=? Fold :call CocActionAsync('fold', <f-args>)
" Coc: use `:OR` for organize import of current buffer
command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')
command! -nargs=0 RenameSym :call CocActionAsync('rename')
command! -nargs=0 ShowDoc :call CocAction('doHover')
command! -nargs=0 CodeAction :call CocAction('codeAction')


call SpaceVim#custom#SPCGroupName(['C'], '+Coc-nvim')
call SpaceVim#custom#SPC('nore', ['C', 'o'], 'CocList outline', 'Buffer symbols outline', 1)
call SpaceVim#custom#SPC('nore', ['C', 'e'], 'CocList extensions', 'List coc-extensions', 1)
call SpaceVim#custom#SPC('nore', ['C', 'f'], 'CocCommand explorer', 'Toggle coc-explorer', 1)
call SpaceVim#custom#SPC('nore', ['C', 'r'], 'Refactor', 'Open coc-refactor window', 1)
call SpaceVim#custom#SPC('nore', ['C', 'c'], 'CocList commands', 'Open fuzzy coc-commands search', 1)
call SpaceVim#custom#SPC('nore', ['C', 'y'], 'CocList -A --normal yank', 'Open yank fuzzy search', 1)
call SpaceVim#custom#SPC('nore', ['C', 'n'], 'RenameSym', 'Rename cword symbol', 1)
call SpaceVim#custom#SPC('nore', ['C', 'h'], 'ShowDoc', 'Show current symbol help', 1)
call SpaceVim#custom#SPC('nore', ['C', 'l'], 'CocList', 'Show CocList', 1)
call SpaceVim#custom#SPC('nore', ['C', 'R'], 'CocCommand workspace.renameCurrentFile', 'Rename current file ,update imports', 1)
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
nnoremap <silent> K :call CocActionAsync('doHover')<CR>
nnoremap <silent> Q :call SpaceVim#mapping#SmartClose()<CR>
inoremap <silent><expr> <c-space> coc#refresh()
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
" nnoremap <silent> lis :call CocAction('organizeImport')<CR>
" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
