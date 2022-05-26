if exists('g:loaded_beaddon')
  finish
endif


if exists('g:bufExplorerDisableDefaultKeyMapping') && g:bufExplorerDisableDefaultKeyMapping==0    " Disable mapping if bufExplorer is enabled
    finish
endif


if !exists('g:buffExplorerAction')
    let g:buffExplorerAction='unite'
endif


let s:availableActions=["ctrlP","unite","bufexplorer", "lusty"]

function! s:setBufferExplorer(explorer) abort
    if index(s:availableActions,a:explorer) > -1
        let g:buffExplorerAction=a:explorer
    else
        echoerr "available actions are " . string(s:availableActions)
    endif
endfunction


function! beaddon#CallExplorer() abort
    if g:buffExplorerAction == 'ctrlP'
        CtrlPBuffer
    elseif g:buffExplorerAction=='unite'
        Unite buffer
    elseif g:buffExplorerAction=='bufexplorer'
        BufExplorer
    elseif g:buffExplorerAction=='lusty'
	LustyBufferExplorer
    endif
endfunction

function! s:getAvailableActions(A, C, P) abort
    if empty(a:A)
        return s:availableActions
    endif
    let result = []
    for i in s:availableActions
        if match(i,'\v^'.a:A.'.*$') > -1
            call add(result,i)
        endif
    endfor

    return result

endfunction

nmap <Leader>b :call beaddon#CallExplorer()<CR>
command! -nargs=1 -complete=customlist,s:getAvailableActions SetBufferExplorer :call s:setBufferExplorer(<f-args>)
let g:loaded_beaddon = 1
