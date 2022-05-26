"===========================================================================
"compile ederken dizine gitmene gerek yok
"ancak bin dizinini bulup dosyalari uygun package degerlerine gore
"yerlestirmesi icin
"cwd parametresinin root dizinine ayarlanmis olmasi gerekli

"run ederken bin dizinini bulabilmesi icin cwd parametresinin root dizinine
"ayarlanmis olmasi gerekli
command! -complete=shellcmd -nargs=+ Shell call s:runShellCommand(<q-args>)
function! s:runShellCommand(cmdline)
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor

  call s:createBuffer()
  
  "call setline(1, 'You entered:    ' . a:cmdline)
  "call setline(2, 'Expanded Form:  ' .expanded_cmdline)
  let seperator="==========================================================================="
  execute '$read !java -version'
  1d
  2,$d
  call setline(line('$')+1,seperator)
  execute '$read !'. expanded_cmdline
  call append(line('$'),seperator)
  setlocal nomodifiable
  1
  nmap <buffer> <silent>q :bd!<CR> 
  nmap <buffer> <silent><Esc> :bd!<CR> 
  " go to upper window
  call s:goto_win(winnr("#"))
endfunction

function! s:createBuffer() abort
  let winnr = bufwinnr("__javavim__")
  if(winnr > -1)
      call s:goto_win(winnr)
      setlocal modifiable
      call s:clearBuffer()
  else
      botright new __javavim__
      "vert belowright new __javavim__
      setlocal buftype=nofile bufhidden=hide noswapfile nowrap
      setlocal nobuflisted
      resize 10
      vertical resize 
  endif
endfunction

function! s:clearBuffer() abort
      "0,$d
      " clear buffer; delete without cutting
      execute "normal! gg\"_dG" 
endfunction



function! s:goto_win(winnr, ...) abort"{{{
    let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w'
                                     \ : 'wincmd ' . a:winnr
    let noauto = a:0 > 0 ? a:1 : 0

    if noauto
        noautocmd execute cmd
    else
        execute cmd
    endif
endfunction"}}}

function! javavim#Wipeout() abort
  if( bufexists("__javavim__"))
     bwipeout __javavim__
  endif
endfunction

func! s:runJava()
" a:firstline, a:lastline secili satirlari alir
    let workingDirectory = getcwd() . "/target"
    let package = s:getPackage()
    let class = s:getClass()
    let command = "java -cp " . workingDirectory . " " . package . class
    "let command = "java -cp ./bin " . package . class

    call s:runShellCommand(command)
endfunc

function! s:getPackage() abort
    let package = ""
    for linenum in range(0, 5)
        let line = getline(linenum)
        if(match(line,"package")> -1)
           let package = split(line)[1]
           let package =  strpart(package,0,strlen(package)-1)
        endif
    endfor
    "let package = input("Enter package: ")
    if (strlen(package) > 0)
        let package = package . "."
    endif
    return package
endfunction

function! s:getClass() abort
    let class = split(bufname("%"),"/")[len(split(bufname("%"),"/"))-1]
    let class = strpart(class,0,strlen(class)-5)
    return class
endfunction

function! javavim#RunJavaWithCompile()
    call s:Compile()
    call s:runJava()
endfunction

function! javavim#RunJavaWithMaven() abort
    let package = s:getPackage()
    let class = s:getClass()
    call s:runShellCommand("mvn clean package exec:java -Dexec.mainClass='".package.class."'")
endfunction
" fonksiyonu debug edebilmek icin 
" breakadd func 1 runJava 
" dedikten sonra 
" debug call runJava() 
" dersen debug modda cagirir kodu

"" bir dosyayi debug edebilmek icin
"" breakadd file 237 myfile.txt

""" breakdel func 5 runJava
""" breakdel *

function! javavim#JavaInsertImport()
  exe "normal mz"
  let cur_class = expand("<cword>")
  try
    if search('^\s*import\s.*\.' . cur_class . '\s*;') > 0
      throw getline('.') . ": import already exist!"
    endif
    wincmd }
    wincmd P
    1
    if search('^\s*public.*\s\%(class\|interface\)\s\+' . cur_class) > 0
      1
      if search('^\s*package\s') > 0
        yank y
      else
        throw "Package definition not found!"
      endif
    else
      throw cur_class . ": class not found!"
    endif
    wincmd p
    normal! G
    " insert after last import or in first line
    if search('^\s*import\s', 'b') > 0
      put y
    else
      1
      put! y
    endif
    substitute/^\s*package/import/g
    substitute/\s\+/ /g
    exe "normal! 2ER." . cur_class . ";\<Esc>lD"
  catch /.*/
    echoerr v:exception
  finally
    " wipe preview window (from buffer list)
    silent! wincmd P
    if &previewwindow
      bwipeout
    endif
    exe "normal! `z"
  endtry
endfunction

function! javavim#RunTest() abort
    let fname = expand("%:p:t:r")

    if(fname !~ '^.*Test$')
        let fname=fname."Test"
    endif


    "let tagName = ""
    "let cmd = "!mvn -DfailIfNoTests=false -Dtest=".fname."\\#".tagName." test"
    let cmd="silent Shell mvn -DfailIfNoTests=false -Dtest=".fname." test"
    exe cmd
endfunction

function! javavim#RunTestMethod() abort
    let fname = expand("%:p:t:r")

    if(fname !~ '^.*Test$')
        echoerr "not a test method"
        return -1
    endif

    let tagName = s:getTagName()
    let cmd = "silent Shell mvn -DfailIfNoTests=false -Dtest=".fname."\\#".tagName." test"

    exe cmd

endfunction

function! s:getTagName() abort
    execute 'normal! [{' 
    let line = getline('.')
    let tagName = matchstr(line,".*void\\s\\zs.*\\ze\(.*") 
    return tagName
endfunction




func! javavim#GetPacketInfo()
    let path = matchstr(expand("%:p:h"),".*src/.*/java/\\zs.*")
    if (empty(path))
        return join(split(expand("%:p:h"),"/")[1:],".")
    endif
    return substitute(path,"/",".","g")
endfunc

function! javavim#NewFile() abort
    silent! 0r $HOME/.vim/templates/%:e.vim_template
    silent! %s/%FILENAME%/\=expand("%:t:r")
    silent! %s/%USER%/\=$USER
    silent! %s/%DATE%/\=strftime('%d.%m.%Y %H:%M')
    let package = javavim#GetPacketInfo()
    if(empty(package))
     silent! g/package/d
    else
        silent! %s/%PACKAGE%/\=package
    endif
    silent g/cursor/d

endfunction

function! s:Compile() abort
    let workingDirectory = getcwd() . "/target"
    if !isdirectory(workingDirectory)
        call mkdir(workingDirectory,"p")
    endif
    exec "w | silent !javac -d ".workingDirectory." %:p:h/*.java"
endfunction

augroup javavimbindings
    autocmd! javavimbindings
    autocmd Filetype java nnoremap <buffer> <silent><Leader>xr :call javavim#RunJavaWithCompile()<CR>
    autocmd Filetype java nnoremap <buffer> <silent><Leader>xta :call javavim#RunTest()<CR>
    autocmd Filetype java nnoremap <buffer> <silent><Leader>xtm :call javavim#RunTestMethod()<CR>
    autocmd Filetype java nnoremap <buffer> <silent>imp  :call javavim#JavaInsertImport()<CR>
    autocmd BufNewFile *.java call javavim#NewFile()
    "autocmd BufWritePost *.java call javavim#Compile()
    autocmd Filetype java command! JavaRunCompile :call javavim#RunJavaWithCompile() 
    autocmd Filetype java command! JavaRunMaven :call javavim#RunJavaWithMaven()
augroup end


let &l:makeprg="mvn"

" to compile a java class
" javac -d target ./*.java

" to run a compiled java class
" java -cp target emrahsoytekin.Desktop.Test.Test
"
" to create executable jar file
" create manifest file 'MANIFEST.MF'
" add main class line
" Main-Class: emrahsoytekin.Desktop.Test.Test
" exec command
" jar cmvf MANIFEST.MF target/Test.jar -C target .
