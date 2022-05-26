function! s:DoPreview()
    let line = getline(".")
    echo "do preview"
endfunction
nnoremap <buffer> <LocalLeader>p :call DoPreview()<CR>
