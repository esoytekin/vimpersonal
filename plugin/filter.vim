" Gather search hits, and display in a new scratch buffer."{{{
function! Gather(pattern)
  if !empty(a:pattern)
    let save_cursor = getpos(".")
    let s:save_bufnr = winnr()
    echo ""
    let orig_ft = &ft
    " append search hits to results list
    let results = []
    execute "g/" . a:pattern . "/call add(results, line('.').':'.getline('.'))"
    call setpos('.', save_cursor)
    if !empty(results)
      " put list in new scratch buffer
      execute "normal! \<C-W>\<C-J>"
      call CloseScratch()
      new
      "vert belowright new
      setlocal buftype=nofile bufhidden=hide noswapfile
      res 5 "set height
      "vertical resize 30
      execute "setlocal filetype=".orig_ft
      call append(1, results)
      1d  " delete initial blank line
      AlignCtrl r:
      Align :
      nmap <buffer> <silent>q :call CloseScratch()<CR>
      nmap <buffer> <silent>o :call GotoLine(getline('.'))<CR> 
      nmap <buffer> <silent><CR> :call SwitchAndGotoLine(getline('.'))<CR> 
      " close opened scratch file 
      nmap <buffer> <silent> <Esc> :call CloseScratch()<CR>
      setlocal nomodifiable
    endif
  endif
endfunction"}}}

" Delete the current buffer if it is a scratch buffer (any changes are lost)."{{{
function! CloseScratch()
  if &buftype == "nofile" && &bufhidden == "hide" && !&swapfile
    " this is a scratch buffer
    set modifiable
    "q
    bdelete
    "e " for vim bug related to syntax highlighting
    execute s:save_bufnr."wincmd w"
    return 1
  endif
  return 0
endfunction"}}}

function! SwitchAndGotoLine(linePattern)"{{{
 if(!empty(a:linePattern))
    let currLine = split(a:linePattern,':')[0]

    "execute "normal! \<C-W>\<C-K>"
    execute s:save_bufnr."wincmd w"
    execute currLine

 endif
endfunction"}}}

function! GotoLine(linePattern)"{{{
 if(!empty(a:linePattern))
    let cur_bufnr = winnr()
    let currLine = split(a:linePattern,':')[0]
    let orjLine = line('.')

    "execute "normal! \<C-W>\<C-K>"
    execute s:save_bufnr."wincmd w"
    execute currLine
    "execute "normal! \<C-W>\<C-J>"
    execute cur_bufnr."wincmd w"
    execute orjLine

 endif
endfunction"}}}
" More simple gather function, lists search results
function! GatherSimple(pattern)"{{{

  if !empty(a:pattern)
     execute "g/".a:pattern
     execute "call GatherSimpleAndGotoLine(input('Line: '))" 
  endif

endfunction"}}}

" prompt user for line number
function! GatherSimpleAndGotoLine(pattern)"{{{
  if !empty(a:pattern)
     execute a:pattern
  endif
endfunction"}}}

" search current buffer for input text
nnoremap <silent> <Leader>f<Space> :call Gather(input("Search for: "))<CR>
" search current buffer for last searched text
nnoremap <silent> <Leader>F : call Gather(@/)<CR>
" search current buffer for input text
command! -nargs=1 GatherSimple :call GatherSimple(<f-args>)
