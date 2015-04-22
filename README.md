# vim-colortuner

Colortuner is a simple utility to allow you tuning your color scheme using 
sliders. It can make any color scheme look great with very little effort.

# Screenshots

![image](https://raw.githubusercontent.com/zefei/vim-colortuner/master/screenshots/screencast1.gif)

# Installation

Use your favorite package manager to install:

* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/zefei/vim-colortuner 
    ~/.vim/bundle/vim-colortuner`
* [Vundle](https://github.com/gmarik/Vundle.vim)
  * `Plugin 'zefei/vim-colortuner'`
* [NeoBundle](https://github.com/Shougo/neobundle.vim)
  * `NeoBundle 'zefei/vim-colortuner'`

# Usage

Once installed, you can type `:Colortuner` to open the tuner panel, then just 
use normal movement keys to adjust settings. Tuner settings are persisted to 
disk on a per-colorscheme basis.

# Configuration

    g:colortuner_filepath
    values: string
    default: '~/.vim-colortuner'
        This option sets the file path of tuner panel settings.

    g:colortuner_enabled
    values: 0 or 1
    default: 1
        Colortuner is enabled at start if this option is set.

    g:colortuner_preferred_schemes
    values: list of strings
    default: []
    example: ['zenburn', 'solarized', 'cake16']
        Colortuner rotates among these colorschemes when you adjust the 
        colorscheme option in tuner panel. If empty list (default) is set, 
        colortuner will rotate among all installed colorschemes.

# FAQ

A: Does colortuner support vim in terminal?

Q: Currently no, since true color support is essential for tuning colors. 
However, Neovim has support for true color terminals, and colortuner supports 
Neovim in the terminal. But notice that at the moment very few terminals work 
well with Neovim true color mode.

# License

MIT License.
