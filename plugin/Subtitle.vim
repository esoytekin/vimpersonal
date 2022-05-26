function! Subtitle()
  execute "%s/ý/ı/g"
  execute "%s/þ/ş/g"
  execute "%s/ð/ğ/g"
  execute "%s/^ı/I/g"
  execute "w ++enc=utf8"
endfunction

command! Sbt :call Subtitle()<CR>
