if exists('g:loaded_colortuner') || !has('gui_running')
  finish
endif
" let g:loaded_colortuner = 1

" commands
command! Colortuner call colortuner#test()
command! ColortunerLighter call colortuner#lighter()
command! ColortunerDarker call colortuner#darker()

nnoremap + :<C-U>ColortunerLighter<CR>
nnoremap - :<C-U>ColortunerDarker<CR>

" configurations
function! s:set(var, value)
  if !exists(a:var)
    let {a:var} = a:value
  endif
endfunction

call s:set('g:colortuner_filepath', '~/.vim-colortuner')

" init colortuner
call colortuner#init()
