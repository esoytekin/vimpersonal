" custom script for prettier
"
"
if exists('g:loaded_prett')
	finish
endif

let g:loaded_prett = 1

function! prett#get_busy(check) abort
	if a:check == 1 && exists('g:prettDisable') && g:prettDisable == 1 
		return
	endif

	exe "!/Users/emrahsoytekin/.nvm/versions/node/v14.18.2/bin/prettier --write %"
endfunction


function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

augroup prettbindigs
    autocmd Filetype javascript.jsx command! PrettThis :call prett#get_busy(0)
    autocmd BufWritePost *.tsx,*.ts,*.js :call prett#get_busy(1)
    autocmd Filetype javascript.jsx command! PrettEnable :let g:prettDisable=0
    autocmd Filetype javascript.jsx command! PrettDisable :let g:prettDisable=1
augroup end

"inoremap <silent><expr> <c-space> coc#refresh()

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

