function! colortuner#init()
  let s:colors = {}
  let s:settings = {}
  let s:settings.brightness = 0

  augroup colortuner_colorscheme
    autocmd!
    autocmd ColorScheme * call colortuner#on_colorscheme()
  augroup END
  call colortuner#on_colorscheme()
endfunction

function! colortuner#test()
  let name = s:get_colorscheme()
  let colors = s:colors[name]

  for [group, value] in items(colors)
    for [key, rgb] in items(value)
      let c = {}
      let c.r = (rgb.r + 255) / 2
      let c.g = (rgb.g + 255) / 2
      let c.b = (rgb.b + 255) / 2

      execute 'highlight '.group.' gui'.key.'='.s:rgb2hex(c)
    endfor
  endfor
endfunction

function! colortuner#lighter()
  let s:settings.brightness += 1
  call s:render()
endfunction

function! colortuner#darker()
  let s:settings.brightness -= 1
  call s:render()
endfunction

function! s:render()
  let colors = s:colors[s:get_colorscheme()]

  for [group, value] in items(colors)
    for [key, rgb] in items(value)
      let color = {}
      for c in keys(rgb)
        let color[c] = s:clip(rgb[c] + s:settings.brightness * 10)
      endfor
      execute 'highlight '.group.' gui'.key.'='.s:rgb2hex(color)
    endfor
  endfor
endfunction

function! s:clip(number)
  if a:number < 0
    return 0
  elseif a:number > 255
    return 255
  else
    return a:number
  endif
endfunction

function! colortuner#on_colorscheme()
  let name = s:get_colorscheme()
  let s:colors[name] = s:get_colors()
endfunction

function! s:get_colorscheme()
  redir => name
  silent colorscheme
  redir END
  return substitute(name,'\_s*\(.\{-}\)\_s*$','\1','')
endfunction

" get colors of all current highlight groups
function! s:get_colors()
  let colors = {}

  " loop over all highlight groups
  let i = 1
  while synIDtrans(i)
    let group = synIDattr(i, "name")

    " skip linked or invalid groups
    if synIDtrans(i) == i && group != ''
      let colors[group] = {}
      for key in ['fg', 'bg']
        let hex = synIDattr(i, key.'#', 'gui')
        if hex != ''
          let colors[group][key] = s:hex2rgb(hex)
        endif
      endfor
    endif

    let i += 1
  endwhile

  return colors
endfunction

" convert hex string to rgb
function! s:hex2rgb(hex)
  let rgb = {}
  let rgb.r = str2nr(a:hex[1:2], 16)
  let rgb.g = str2nr(a:hex[3:4], 16)
  let rgb.b = str2nr(a:hex[5:6], 16)
  return rgb
endfunction

" convert rgb to hex string
function! s:rgb2hex(rgb)
  return printf('#%02x%02x%02x', a:rgb.r, a:rgb.g, a:rgb.b)
endfunction

" convert rgb to hsl in place
function! s:rgb2hsl(rgb)
  let r = a:rgb.r / 255.0
  let g = a:rgb.g / 255.0
  let b = a:rgb.b / 255.0
  let rgb = [a:rgb.r, a:rgb.g, a:rgb.b]
  let M = max(rgb) / 255.0
  let m = min(rgb) / 255.0
  let c = M - m
  let l = (M + m) / 2

  if c == 0
    let h = 0.0
    let s = 0.0
  else
    if M == r
      let h = (g - b) / c + (g < b ? 6 : 0)
    elseif M == g
      let h = (b - r) / c + 2
    else
      let h = (r - g) / c + 4
    endif
    let s = l > 0.5 ? c / (2 - M - m) : c / (M + m)
  endif

  let a:rgb.h = h
  let a:rgb.s = s
  let a:rgb.l = l
  return a:rgb
endfunction

" convert hsl to rgb in place
