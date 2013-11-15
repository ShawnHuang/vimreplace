
if exists('g:loaded_autoload_vimreplace') 
  finish
endif

let g:loaded_autoload_vimreplace=1

let s:save_cpo = &cpo
set cpo&vim

fun! vimreplace#clear()
  redraw
  echo ""
  "if exists(a:mid)
  "  call matchdelete(a:mid)
  "endif
  "if exists(a:incid)
  "  call matchdelete(a:incid)
  "endif
  if hasmapto('dbd73c2b545209688ed794c0d5413d5a<CR>')
    exec 'cunmap '.g:vimreplace_quit_key
  endif
  redraw
endfun

fun! vimreplace#getResultPos(pat)
    let s:curchar= getline(".")[col(".")-1]
    if s:curchar=='b'
      norm! ic
    else
      norm! ib
    endif
    let s:matchpos = searchpos(a:pat,'Wn')
    let s:matchpos[1]-=1
    norm! x
    redraw
    return s:matchpos
endfun

fun! vimreplace#comparePos(var1,var2)
   " -1 var1<var2
   "  1 var1==var2
   "  0 var1>var2
   if a:var1[0]<a:var2[0]
     return -1
   endif
   
   if a:var1[0]==a:var2[0]
     if a:var1[1]==a:var2[1]
       return 1
     endif
     if a:var1[1]<a:var2[1]
       return -1
     endif
   endif
   return 0
endfun
fun! vimreplace#setWord(word,matchpos,pat,curpos)
  let a:word.begin = a:matchpos[1]-1
  let a:word.end = matchend(getline("."),a:pat,a:word.begin)
  let a:word.len = a:word.end - a:word.begin
  let a:word.dis = a:curpos[1] - a:word.begin
  let a:word.match = getline(".")[eval(a:word.begin):eval(a:word.end-1)]
endfun
let &cpo = s:save_cpo
