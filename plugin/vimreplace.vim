if exists("g:loaded_vimreplace")
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let s:default_replace_key = '<Leader>y'
let s:default_quit_replace_key = '<C-c>'

let g:vimreplace_replace_key = get(g:, 'vimreplace_replace_key', s:default_replace_key)
let g:vimreplace_quit_key = get(g:, 'vimreplace_quit_key', s:default_quit_replace_key)

if !hasmapto('<Plug>VimReplace')
  exec 'map <unique> '.g:vimreplace_replace_key.' <Plug>VimReplace'
endif
noremap <unique> <script> <Plug>VimReplace  <SID>Replace

nnoremap <SID>Replace  :call <SID>Replace()<CR>
vnoremap <SID>Replace  :call <SID>Replacev()<CR>

fun s:Replace()
  exec 'cmap '.g:vimreplace_quit_key.' dbd73c2b545209688ed794c0d5413d5a<CR>'
  let s:pat = @/
  let s:curpos= [line("."),col(".")]
  let s:curchar= getline(".")[col(".")-1]
  let s:found=0
  
  "forward result pos[line,column]
  let s:matchpos = searchpos(s:pat,'Wbn')

  "這一行變數沒有即時更新
  let s:word = {}

  call vimreplace#setWord(s:word,s:matchpos,s:pat,s:curpos)

  if empty(s:pat)
    call vimreplace#clear()
    return
  endif 
  
  "check if there is any result in this buffer
  if !search(s:pat,'wn')
    call vimreplace#clear()
    return
  endif  


  ""if pos at [1,1], and no result
  "if s:matchpos[0]==0
  "  if s:matchpos[0]==s:curline
  "    if s:matchpos[1] == s:curcol
  "      let s:matchpos=vimreplace#getResultPos(s:pat)
  "    else
  "      call vimreplace#clear(s:mid,s:incid)
  "      return
  "    endif
  "  endif
  "endif


  "cursor所在的這一行，cursor之前(不含cursor)無搜尋結果
  if (vimreplace#comparePos(s:matchpos,[0,0])==1)||(vimreplace#comparePos(s:matchpos,[s:curpos[0],0])==-1)
    let s:matchpos=vimreplace#getResultPos(s:pat)
    call vimreplace#setWord(s:word,s:matchpos,s:pat,s:curpos)
    if vimreplace#comparePos(s:matchpos,s:curpos)==1
      "剛好在cursor上
      let s:found = 1
      echo "The result in this line on cursor"
      call getchar()
    endif
    "if vimreplace#comparePos(s:matchpos,[s:curpos[0]+1,0])==0
    "  call vimreplace#clear()
    "  return
    "endif
  else
    echo "The result in this line before cursor"
    call getchar()
    
    "這一行前面有一個result,但不是cursor所在的result
    if s:word.len>=s:word.dis
      norm! N
      let s:found=1
    else
      let s:matchpos=vimreplace#getResultPos(s:pat)
      call vimreplace#setWord(s:word,s:matchpos,s:pat,s:curpos)
      if vimreplace#comparePos(s:matchpos,s:curpos)==1
        "剛好在cursor上
        let s:found = 1
        echo "The result in this line on cursor"
        call getchar()
      endif
    endif
  endif

  if s:found==1
    "highlight result and cusor
    let s:mid = matchadd("Search",s:pat)
    let s:incid = matchadd("IncSearch",'\%#'.s:pat)
    redraw

    let s:RWord = input("Find:'".s:word.match."', Replace With: ")
    if !empty(matchstr(s:RWord,"dbd73c2b545209688ed794c0d5413d5a",0))
      "norm! h
      call vimreplace#clear()
    else
      s/\%#./\r&/
      try
        exe "s/".s:pat."/".s:RWord."/"
        echo ""
      catch
        redraw
        echo "No text to replace. "
      endtry
      let s:curpos[1]= s:word.begin + matchend(getline("."),s:RWord)
      "echo curcol
      norm! k
      j!
      exe 'norm! '.s:curpos[1].'|' 
      call vimreplace#clear()
    endif
    call matchdelete(s:mid)
    call matchdelete(s:incid)
  endif
  "the result at curline

  "跟字的第一字元距離是否大於字的長度
  "if s:wordlen<s:curdis
  "  let s:matchpos=vimreplace#getResultPos(s:pat)
  "  if s:matchpos[0]==s:curline
  "    if s:matchpos[1] == s:curcol
  "    else
  "      call vimreplace#clear(s:mid,s:incid)
  "      return
  "    endif
  "  endif
  "endif
  "the result at curline
  "if s:matchpos[0] == s:curline
  "  let s:wordbegin = s:matchpos[1]-1
  "  let s:wordend = matchend(getline("."),s:pat,s:wordbegin)
  "  let s:wordlen = s:wordend - s:wordbegin
  "  let s:curdis = s:curcol - s:wordbegin
  "  let s:curword = getline(".")[eval(s:wordbegin):eval(s:wordend-1)]
  "else
  "  call vimreplace#clear(s:mid,s:incid)
  "  return
  "endif
  "跟字的第一字元距離是否小於字的長度
"  if s:wordlen>=s:curdis
"
"
"    s/\%#./\r&/
"    try
"      exe "s/".s:pat."/".s:TempWord."/"
"      echo ""
"    catch
"      redraw
"      echo "No text to replace. "
"    endtry
"    let s:curcol= s:wordbegin + matchend(getline("."),s:TempWord)
"    "echo curcol
"    norm! k
"    j!
"    exe 'norm! '.s:curcol.'|'
"    "call search(@/)
"  endif
"  call vimreplace#clear(s:mid,s:incid)
endfun

fun s:Replacev()
  echo "Im replacev"
endfun

let &cpo = s:save_cpo
"let loop =1
"while loop 
"  redraw
"  echo "Cancel? ... 'y/n'"
"  let cancel = getchar()
"  if cancel == 121
"    let loop=0
"    redraw
"    echo ""
"    call matchdelete(s:mid)
"    call matchdelete(s:incid)
"    cunmap <C-c>
"    return
"  elseif cancel ==110
"    let loop=0
"  else
"  endif
"endwhile
"let s:espat = escape(s:pat," \/")
