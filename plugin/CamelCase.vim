" a function to generate the 'mCC' abbreviation from the 'myCamelCase' string
function! Camel_Initials(camel)
    let first_char = matchstr(a:camel,"^.")
    let other_char = substitute(a:camel,"\\U","","g")
    return first_char . other_char
endfunction

" function that takes an abbreviation ('mCC') and scans the current buffer
" (backwards from the current line) for 'words' that have this abbreviation. A
" list of all matches is returned
function! Expand_Camel_Initials(abbrev)
    let winview=winsaveview()
    let candidate=a:abbrev
    let matches=[]
    try
        let resline = line(".")
        while resline >= 1
            let sstr = '\<' . matchstr(a:abbrev,"^.") . '[a-zA-Z]*\>'
            keepjumps let resline=search(sstr,"bW")
            let candidate=expand("<cword>")
            if candidate != a:abbrev && Camel_Initials(candidate) == a:abbrev
                call add( matches, candidate )
            endif
        endwhile
    finally
        call winrestview(winview)
        if len(matches) == 0
            echo "No expansion found"
        endif
        return sort(matches)
    endtry
endfunction

"Next, here's a custom-completion function that reads the word under the
"cursor and suggests the matches returned by the above functions:
function! Camel_Complete( findstart, base )
    if a:findstart
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '[A-Za-z_]'
            let start -= 1
        endwhile
        return start
    else
        return Expand_Camel_Initials( a:base )
    endif
endfunction





