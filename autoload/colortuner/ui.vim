function! colortuner#ui#open()
  let buffer = bufnr('__colortuner__')

  if buffer == -1
    execute 'botright new __colortuner__'
  else
    let window = bufwinnr(buffer)

    if window == -1
      execute 'botright split +buffer'.buffer
    else
      execute window.'wincmd w'
    endif
  endif

  call s:render()
  execute 3
endfunction

function! s:render()
  setlocal modifiable
  silent! execute '1,$ delete _'
  let setting = colortuner#get_setting()
  let s = setting.setting
  call append(0, [
        \'  Color scheme     '.setting.name,
        \'',
        \'  Brightness       '.s.brightness,
        \'  Contrast         '.s.contrast,
        \'  Saturation       '.s.saturation,
        \'  Hue              '.s.hue,
        \'',
        \'  Enabled         '.(setting.enabled ? 'Yes' : 'No'),
        \'  Inverted        '.(s.inverted ? 'Yes' : 'No')])
  setlocal nomodifiable
endfunction

function! s:tune(dir)
  let l = line('.')

  if l == 3
    call colortuner#set('brightness', a:dir)
  elseif l == 4
    call colortuner#set('contrast', a:dir)
  elseif l == 5
    call colortuner#set('saturation', a:dir)
  elseif l == 6
    call colortuner#set('hue', a:dir)
  elseif l == 8
    call colortuner#set('enabled', a:dir)
  elseif l == 9
    call colortuner#set('inverted', a:dir)
  endif

  call s:render()
  execute l
endfunction

function! s:reset()
  let l = line('.')
  call colortuner#reset()
  call s:render()
  execute l
endfunction

" setup colortuner buffer window
function! colortuner#ui#setup()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodifiable
  setlocal filetype=colortuner
  setlocal nolist
  setlocal nonumber
  setlocal norelativenumber
  setlocal nowrap
  setlocal colorcolumn=
  setlocal cursorline
  let &l:statusline = ' colortuner | h/l/-/+: adjust | r: reset | q: quit'
  execute '10 wincmd _'

  nnoremap <script> <silent> <buffer> h :call <SID>tune(-1)<CR>
  nnoremap <script> <silent> <buffer> <left> :call <SID>tune(-1)<CR>
  nnoremap <script> <silent> <buffer> - :call <SID>tune(-1)<CR>
  nnoremap <script> <silent> <buffer> l :call <SID>tune(1)<CR>
  nnoremap <script> <silent> <buffer> <right> :call <SID>tune(1)<CR>
  nnoremap <script> <silent> <buffer> + :call <SID>tune(1)<CR>
  nnoremap <script> <silent> <buffer> r :call <SID>reset()<CR>
  nnoremap <script> <silent> <buffer> q :quit<CR>
endfunction
