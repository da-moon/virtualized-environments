"set autochdir
" https://github.com/fatih/vim-go/blob/master/doc/vim-go.txt
let g:go_doc_popup_window = 1

" let g:go_list_height = 5
let g:go_list_type = "quickfix"
let g:go_debug = [
      \"shell-commands",
\]
let g:go_rename_command = 'gopls'
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
let g:go_gopls_config={
  \'fillreturns': v:true
  \}
let g:go_highlight_functions = 1
let g:go_textobj_include_function_doc = 1
" add snakecase tags to structs
let g:go_addtags_transform = "snakecase"
let g:go_decls_includes = "func,type"

let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"

" Show type information in status line
let g:go_auto_type_info = 1

let g:go_auto_sameids = 1



let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_methods = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_metalinter_autosave = 1
" let g:go_metalinter_command='golangci-lint run'
" let g:go_metalinter_autosave_enabled = ['revive']
" let g:go_metalinter_command='golangci-lint'
" let g:go_metalinter_enabled = [
"   \'bodyclose',
"   \'dogsled',
"   \'gochecknoglobals',
"   \'gochecknoinits',
"   \'gocognit',
"   \'gocritic',
"   \'gocyclo',
"   \'golint',
"   \'gosec',
"   \'misspell',
"   \'nakedret',
"   \'prealloc',
"   \'scopelint',
"   \'unconvert',
"   \'unparam',
"   \'whitespace',
" 	\'vet',
" 	\'golint',
" 	\'errcheck',
" 	\'deadcode', 
" 	\'structcheck',
" 	\'maligned',
" 	\'megacheck',
" 	\'dupl',
" 	\'interfacer',
" 	\'goconst',
"   \'gosimple', 
"  	\'govet', 
" 	\'staticcheck', 
" 	\'typecheck', 
" 	\'unused', 
" 	\'varcheck'
" \]
" let g:go_metalinter_deadline = "5s"
