" Extra ngspice highlighting, loaded on top of Neovim's built-in
" syntax/spice.vim (which only covers comments, numbers, dot commands,
" brackets and + continuation lines)

syn case ignore

" first line of a netlist is always the title, ngspice never runs it
syn match spiceTitle "\%1l.*"

" instance name at the start of a component line (R1, Mn, Xinv, Vdd...)
syn match spiceDevice "^\s*[a-z]\S*"

" ngspice ignores letters after the scale suffix (1pf, 10ns, 1kohm), so
" colour them as part of the number
syn match spiceNumber "\<[0-9]\+\.\=[0-9]*\(e[-+]\=[0-9]\+\)\=\(meg\|mil\|[tgkmunpfa]\)\=[a-z]*\>"
syn match spiceNumber "\.[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\|mil\|[tgkmunpfa]\)\=[a-z]*\>"

" name= in W=0.4u, val=0.5, rise=2, ...
syn match spiceParamName "\<\h\w*\ze\s*="

" model kind right after .model <name>
syn match spiceModelType "\%(^\s*\.model\s\+\S\+\s\+\)\@<=\h\w*"

" {expressions} in .param and component values
syn region spiceBrace matchgroup=spiceExpr start="{" end="}" contains=spiceNumber,spiceParen,spiceParamName

" .control ... .endc is ngspice's script language, not netlist lines
syn region spiceControl matchgroup=spiceStatement start="^\s*\.control\>" end="^\s*\.endc\>"
      \ contains=spiceCtrlComment,spiceCommand,spiceFlow,spiceString,spiceVar,spiceNumber,spiceParen,spiceParamName
syn match spiceCtrlComment contained "^\s*\*.*$" contains=spiceTodo,@Spell
syn region spiceString contained start=+"+ skip=+\\"+ end=+"+ contains=spiceVar
syn match spiceVar contained "\$&\=\h\w*\%(([^)]*)\)\="
syn keyword spiceFlow contained foreach end if else while repeat dowhile break continue label goto
syn keyword spiceCommand contained let set unset echo print plot asciiplot meas measure
      \ tran ac dc op noise pz sens disto tf run reset alter alterparam save write
      \ wrdata wrs2p load linearize display destroy setplot setscale listing show
      \ showmod fft spec fourier define undefine compose alias unalias source shell
      \ quit exit option options rusage version remcirc cd status stop resume
      \ step trace iplot hardcopy gnuplot settype

hi def link spiceTitle       Title
hi def link spiceDevice      Type
hi def link spiceModelType   Structure
hi def link spiceParamName   Identifier
hi def link spiceCtrlComment Comment
hi def link spiceString      String
hi def link spiceVar         Identifier
hi def link spiceFlow        Repeat
hi def link spiceCommand     Function
