let g:coc_preferences = {
  \ "autoTrigger": "always",
  \ "maxCompleteItemCount": 10,
  \ "codeLens.enable": 1,
  \ "diagnostic.virtualText": 1,
\}
let g:coc_start_at_startup    = 1
let g:coc_force_debug = 1
let g:coc_disable_startup_warning = 1
let g:UltiSnipsExpandTrigger = "<nop>"

autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=0 Refactor :call CocActionAsync('refactor')
command! -nargs=? Fold :call CocActionAsync('fold', <f-args>)
command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')
command! -nargs=0 RenameSym :call CocActionAsync('rename')
command! -nargs=0 ShowDoc :call CocAction('doHover')
command! -nargs=0 CodeAction :call CocAction('codeAction')
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
autocmd CursorHold * silent call CocActionAsync('highlight')
nnoremap <silent> K :call CocActionAsync('doHover')<CR>
nnoremap <silent> Q :call SpaceVim#mapping#SmartClose()<CR>
inoremap <silent><expr> <c-space> coc#refresh()
nnoremap <silent> K :call <SID>show_documentation()<CR>
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
