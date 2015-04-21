" convert hex string to rgb
function! colortuner#conv#hex2rgb(hex)
  let rgb = {}
  let rgb.r = str2nr(a:hex[1:2], 16)
  let rgb.g = str2nr(a:hex[3:4], 16)
  let rgb.b = str2nr(a:hex[5:6], 16)
  return rgb
endfunction

" convert rgb to hex string
function! colortuner#conv#rgb2hex(rgb)
  return printf('#%02x%02x%02x', a:rgb.r, a:rgb.g, a:rgb.b)
endfunction

" convert rgb [0, 255] to hsl [0, 1] in place
function! colortuner#conv#rgb2hsl(rgb)
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
    let h = h / 6
    let s = l > 0.5 ? c / (2 - M - m) : c / (M + m)
  endif

  let a:rgb.h = h
  let a:rgb.s = s
  let a:rgb.l = l
  return a:rgb
endfunction

" convert hsl [0, 1] to rgb [0, 255] in place
function! colortuner#conv#hsl2rgb(hsl)
  let h = a:hsl.h
  let s = a:hsl.s
  let l = a:hsl.l
  let r = l
  let g = l
  let b = l

  if s != 0
    let q = l < 0.5 ? l * (1 + s) : l + s - l * s
    let p = 2 * l - q
    let r = s:hue2rgb(p, q, h + 1.0/3)
    let g = s:hue2rgb(p, q, h)
    let b = s:hue2rgb(p, q, h - 1.0/3)
  endif

  let a:hsl.r = float2nr(r * 255)
  let a:hsl.g = float2nr(g * 255)
  let a:hsl.b = float2nr(b * 255)
  return a:hsl
endfunction

" helper function for hsl2rgb
function! s:hue2rgb(p, q, t)
  let t = a:t
  let t += t < 0 ? 1 : 0
  let t -= t > 1 ? 1 : 0
  if t < 1.0/6
    return a:p + (a:q - a:p) * 6 * t
  elseif t < 0.5
    return a:q
  elseif t < 2.0/3
    return a:p + (a:q - a:p) * (2.0/3 - t) * 6
  else
    return a:p
  endif
endfunction
