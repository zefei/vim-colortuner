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
        \'  Colorscheme   '.setting.name,
        \'',
        \'  Brightness    '.s:make_slider(s.brightness, -50, 50),
        \'  Contrast      '.s:make_slider(s.contrast, -50, 50),
        \'  Saturation    '.s:make_slider(s.saturation, -50, 50),
        \'  Hue           '.s:make_slider(s.hue, -180, 180)."\u00b0",
        \'',
        \'  Enabled       '.(setting.enabled ? 'Yes' : 'No'),
        \'  Inverted      '.(s.inverted ? 'Yes' : 'No')])
  setlocal nomodifiable
endfunction

function! s:make_slider(value, m, M)
  let width = 31
  let n = float2nr(1.0 * (a:value - a:m) / (a:M - a:m) * width)
  return repeat('#', n).repeat('-', width - n).'  '.(a:value > 0 ? '+' : '').a:value
endfunction

function! s:tune(delta)
  let l = line('.')

  if l == 1
    call colortuner#rotate_colorscheme(a:delta)
  elseif l == 3
    call colortuner#set('brightness', a:delta)
  elseif l == 4
    call colortuner#set('contrast', a:delta)
  elseif l == 5
    call colortuner#set('saturation', a:delta)
  elseif l == 6
    call colortuner#set('hue', a:delta)
  elseif l == 8
    call colortuner#set('enabled', a:delta)
  elseif l == 9
    call colortuner#set('inverted', a:delta)
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
  let &l:statusline = ' colortuner | h/l/-/+/b/w: adjust | r: reset | q: quit'
  execute '10 wincmd _'

  nnoremap <script> <silent> <buffer> h :<C-U>call <SID>tune(-v:count1)<CR>
  nnoremap <script> <silent> <buffer> <left> :<C-U>call <SID>tune(-v:count1)<CR>
  nnoremap <script> <silent> <buffer> - :<C-U>call <SID>tune(-v:count1)<CR>
  nnoremap <script> <silent> <buffer> b :<C-U>call <SID>tune(-5*v:count1)<CR>
  nnoremap <script> <silent> <buffer> l :<C-U>call <SID>tune(v:count1)<CR>
  nnoremap <script> <silent> <buffer> <right> :<C-U>call <SID>tune(v:count1)<CR>
  nnoremap <script> <silent> <buffer> + :<C-U>call <SID>tune(v:count1)<CR>
  nnoremap <script> <silent> <buffer> w :<C-U>call <SID>tune(5*v:count1)<CR>
  nnoremap <script> <silent> <buffer> r :<C-U>call <SID>reset()<CR>
  nnoremap <script> <silent> <buffer> q :<C-U>quit<CR>
endfunction
