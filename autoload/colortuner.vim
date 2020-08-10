function! colortuner#init()
  let s:colors = {}
  let s:enabled = g:colortuner_enabled
  let s:schemes = g:colortuner_preferred_schemes
  call colortuner#load()

  augroup colortuner_colorscheme
    autocmd!
    autocmd ColorScheme,VimEnter * call colortuner#on_colorscheme()
    autocmd VimEnter * call colortuner#get_all_colorschemes()
    autocmd BufEnter __colortuner__ call colortuner#ui#setup()
    autocmd VimLeave * call colortuner#save()
  augroup END
endfunction

function! colortuner#load()
  let file = expand(g:colortuner_filepath)
  let settings = filereadable(file) ? readfile(file) : []
  if len(settings) == 1
    execute 'let s:settings = '.settings[0]
  else
    let s:settings = {}
  endif
endfunction

function! colortuner#save()
  call writefile([string(s:settings)], expand(g:colortuner_filepath))
endfunction

function! colortuner#on_colorscheme()
  let name = s:get_colorscheme()
  let s:colors[name] = s:get_colors()
  if !has_key(s:settings, name)
    call colortuner#reset()
  else
    call s:render()
  endif
endfunction

function! colortuner#get_all_colorschemes()
  if s:schemes != []
    return
  endif

  for fname in split(globpath(&runtimepath, 'colors/*.vim'), '\n')
    let name = fnamemodify(fname, ':t:r')
    let s:schemes += [name]
  endfor
endfunction

function! s:get_colorscheme()
  redir => name
  silent colorscheme
  redir END
  return substitute(name,'\_s*\(.\{-}\)\_s*$','\1','')
endfunction

function! colortuner#reset()
  let name = s:get_colorscheme()
  let s:settings[name] = {'inverted': 0,
        \'brightness': 0, 'contrast': 0, 'saturation': 0, 'hue': 0}
  call s:render()
endfunction

function! colortuner#get_setting()
  let name = s:get_colorscheme()
  return {'enabled': s:enabled, 'name': name, 'setting': s:settings[name]}
endfunction

function! colortuner#set(attr, delta)
  let s = s:settings[s:get_colorscheme()]
  if a:attr == 'enabled'
    let s:enabled = !s:enabled
  elseif a:attr == 'inverted'
    let s.inverted = !s.inverted
  else
    let step = {'brightness': 1, 'contrast': 1, 'saturation': 1, 'hue': 5}
    let m = {'brightness': -50, 'contrast': -50, 'saturation': -50, 'hue': -180}
    let M = {'brightness': 50, 'contrast': 50, 'saturation': 50, 'hue': 180}
    let s[a:attr] = s:clamp(s[a:attr] + a:delta * step[a:attr], m[a:attr], M[a:attr])
  endif
  call s:render()
endfunction

function! colortuner#rotate_colorscheme(delta)
  let name = s:get_colorscheme()
  let i = index(s:schemes, name)
  let n = len(s:schemes)
  let i = (i + a:delta) % n
  let i += i < 0 ? n : 0
  execute 'colorscheme '.s:schemes[i]
endfunction

function! colortuner#yank()
  " Will work with any register, and with unamedplus register
  " e.g. "ayy
  exe "let @".v:register."='".s:current_colors."'"
  echom "Colors yanked to register ".v:register
endfunction

function! s:render()
  let name = s:get_colorscheme()
  let colors = s:colors[name]
  let s:current_colors = ''

  for [group, value] in items(colors)
    if empty(value)
      continue
    endif
    let cmd = 'highlight '.group
    for [key, color] in items(value)
      let c = s:apply(color, s:settings[name])
      let cmd = cmd.' gui'.key.'='.colortuner#conv#rgb2hex(c)
    endfor
    let s:current_colors = s:current_colors.cmd."\n"
    execute cmd
  endfor
endfunction

function! s:apply(color, setting)
  if !s:enabled
    return a:color
  endif

  let color = copy(a:color)

  let color.h = (float2nr(color.h * 360) + a:setting.hue + 360) % 360 / 360.0
  let color.s = s:clamp(color.s + a:setting.saturation / 100.0, 0.0, 1.0)

  let c = a:setting.contrast
  let f = (80.0 + c) / (80.0 - c)
  let b = a:setting.brightness

  " only invert lightness, not hue, this is better than negative color
  if a:setting.inverted
    let color.l = 1 - color.l
  endif

  " vivid mode, default to 0, decides tuning methods with the chart below
  " vivid?   |   contrast/brightness value   |   tuning method
  " false    |   > 0                         |   tune on lightness
  " false    |   < 0                         |   tune on rgb separately
  " true     |   > 0                         |   tune on rgb separately
  " true     |   < 0                         |   tune on lightness
  let vivid = g:colortuner_vivid_mode

  if c > 0 && !vivid || c < 0 && vivid
    let color.l = f * (color.l - 0.5) + 0.5
  endif

  if b > 0 && !vivid || b < 0 && vivid
    let color.l = color.l + b / 100.0
  endif

  call colortuner#conv#hsl2rgb(color)

  if c < 0 && !vivid || c > 0 && vivid
    let color.r = float2nr(f * (color.r - 128) + 128)
    let color.g = float2nr(f * (color.g - 128) + 128)
    let color.b = float2nr(f * (color.b - 128) + 128)
  endif

  if b < 0 && !vivid || b > 0 && vivid
    let color.r = float2nr(color.r + b * 2.55)
    let color.g = float2nr(color.g + b * 2.55)
    let color.b = float2nr(color.b + b * 2.55)
  endif

  let color.r = s:clamp(color.r, 0, 255)
  let color.g = s:clamp(color.g, 0, 255)
  let color.b = s:clamp(color.b, 0, 255)

  return color
endfunction

function! s:clamp(number, m, M)
  if a:number < a:m
    return a:m
  elseif a:number > a:M
    return a:M
  else
    return a:number
  endif
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
        if len(hex) == 7 && hex[0] == '#' && hex != '#000000'
          let colors[group][key] = colortuner#conv#rgb2hsl(colortuner#conv#hex2rgb(hex))
        endif
      endfor
    endif

    let i += 1
  endwhile

  return colors
endfunction
