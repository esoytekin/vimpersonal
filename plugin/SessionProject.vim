" 
" 1. :cd <project path>
" 2. :Project ~/Dropbox/SyncApps/Projects/<projectname> -> :Project  ~/Dropbox/SyncApps/Projects/angular-totp
" 3. :SaveSession <projectname> -> :SaveSession angular-totp
" 4. :GetSession <projectname>



function! GetProjectPrivateFunction(regex) abort
  let glp = split(globpath('~/Dropbox/SyncApps/Projects/','*'),'\n')
  let results = ''
  let i =0

  for needle in glp
      " code
      if i < len(glp)
          let mt = matchstr(needle,a:regex)
          let results = results.mt
          if i+1 != len(glp)
            let results = results."\n"
          endif
      endif
      let i +=1
  endfor
  return results

endfunction


func! GetProject(ArgLead, CmdLine, CursorPos)
  let regex = '^.*\\\zs.*$'
  return GetProjectPrivateFunction(regex)
endfunc

func! GetProjectMac(ArgLead, CmdLine, CursorPos)
  let regex = '^.*\/\zs.*$'
  return GetProjectPrivateFunction(regex)
endfunc

func! GetSession(proc)
    exec "SessionOpen ".a:proc.".vim"
    let comm = '~/Dropbox/SyncApps/Projects/'.a:proc
    let comm="Project ".comm
    exec comm
endfunc
command! -nargs=1 -complete=custom,GetProject GetSession :call GetSession(<f-args>)
command! -nargs=1 -complete=custom,GetProjectMac GetSessionMac :call GetSession(<f-args>)
