let s:fromels=["i","s","o","c","g","u"]
let s:toels=["ı","ş","ö","ç","ğ","ü"]

function! s:convertCmd(cmd,from,to) abort
    for i in range(0, len(a:from)-1)
        let command = a:cmd."/\\\\".a:from[i]."/".a:to[i]."/eg"
        exec command
    endfor
endfunction

function! utf8#convertTo() abort
    call s:convertCmd("%s",s:fromels, s:toels)
endfunction

function! utf8#convertRangeTo() range
    call s:convertCmd(a:firstline. "," . a:lastline . "s", s:fromels, s:toels)
endfunction

command! -nargs=0 Cutf :call utf8#convertTo()
command! -range -nargs=0 CutfRange <line1>,<line2>call utf8#convertRangeTo()
