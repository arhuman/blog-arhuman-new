+++
author = "Arnaud ASSAD"
date = "2017-09-15"
description = ""
featured = ""
featuredalt = ""
featuredpath = ""
linktitle = "configure_vim_from_scratch"
title = "Configure Vim from scratch"
type = "post"
tags = ["Vim", "Tutorial", "Configuration"]
categories = ["Article"]
+++

# Configure Vim from scratch

From time to time, I review my tools/processes to keep what’s useful, ditch what is no longer necessary or even convenient, and improve what can be improved. As a developer, I spend a lot of time using the Vim text editor, so in this article I’ll spend some time rewriting my `.vimrc`.

> “Give me six hours to chop down a tree and I will spend the first four sharpening the axe.”
> ― Abraham Lincoln

I used to configure my vim, using several files: A `~/.vimrc` loading different others files noticely one for my keys configuration (`~/.vim/vim-keys`) another one for my configuraton (`~/.vim/vim-config`). The rationale behind this (too) complex setup, was that my `.vimrc` was going too big, and I wanted to make the things more managable, structured this way.

After several years of use, I’ve come to think that this was maybe the wrong answer to the issue. This time I’ve decided to tackle this complexity by declutering/symplifying my `~/.vimrc`. Follow me, as I rewrite a `~/.vimrc` from scratch.

### Minimal ~/.vimrc

The first step is to move the existing .vim configuration out of my way.

    mv .vim .vim_disabled
    mv .vimrc .vimrc_disabled

Vim plugins ecosystem is simply awesome, and to leverage its power, I’d strongly suggest using a plugin manager. In the past I used Vimana, Pathogen, Neobundle and other people are still happy with Vundle, Dein, VAM to name few.

Now, I use Plug: Plug is simple, fast and offer some interesting features like lazy/on demand loading, automatic plugin install/update, and parallel updates.

Getting plug installed is as simple as:

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs [https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim)

Creating minimal `~/.vimrc` isn’t more complicated:

```
" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

"  You will load your plugin here
"  Make sure you use single quotes
" Initialize plugin system
call plug#end()
```

Before we move on further let’s add one handy configuration:

```
let mapleader = ','
```

The leader key will be used below in our keys configuration.

### Adding plugins

Now that we have Plug installed, let’s add some useful plugins to improve our productivity.

### NO NerdTree

I don’t need nerdTree. It took me some times to figure it out, but I don’t need no NerdTree nor any other file explorer plugin.

Vim comes with netrw included, so all you need is a little bit of configuration:

```
" absolute width of netrw window
let g:netrw_winsize = -28

" tree-view
let g:netrw_liststyle = 3

" sort is affecting only: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'

" open file in a new tab
let g:netrw_browse_split = 3
```

With this configuration, you’ve got a decent file explorer, and coupled with fuzzy search (see below) you have all that’s needed to manipulate your files.

### tcomment

Commenting a line is quite frequent, so let’s make it efficiently. With tcomment you get one unified (fast) way to comment (multi)lines whatever the language.

With Plug installed, adding a plugin only require one additional line in the `~/.vimrc`

```
    Plug 'tomtom/tcomment_vim'
```

One additional line to customize the associated key:

```
" Leader C is the prefix for code related mappîngs 
noremap <silent> <Leader>cc :TComment<CR>
```

And eventually to automatically download and install the plugin, execute `PlugInstall()` in vim:

```
:PlugInstall
```

Now you can simply (un)comment a line or visually selected lines by typing `,cc`

### CtrlP

Fuzzy search is great, CtrlP brings it into vim.

The installation is always requiring on additional line in `~/.vimrc`:

```
Plug 'ctrlpvim/ctrlp.vim'
```

And the configuring the keys, follow the same routine:

```
" absolute width of netrw window
" Leader F is for file related mappîngs (open, browse...) 
nnoremap <silent> <Leader>f :CtrlP<CR>
nnoremap <silent> <Leader>fm :CtrlPMRU<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ctrl B for buffer related mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <Leader>b :CtrlPBuffer<CR> " cycle between buffer
nnoremap <silent> <Leader>bb :bn<CR> "create (N)ew buffer
nnoremap <silent> <Leader>bd :bdelete<CR> "(D)elete the current buffer
nnoremap <silent> <Leader>bu :bunload<CR> "(U)nload the current buffer
nnoremap <silent> <Leader>bl :setnomodifiable<CR> " (L)ock the current buffer"
```

As a side note: By now, you should start to understand the logic in my key mapping. I use “prefix” to group key sequences logically: `,c` for code related commands `,f` for file related commands `,b` for buffer related commands `,g `for git (SCM) related commands

This helps me organize/remember, my custom mappings.

As usual, you’ll have to install it (only the first time) with:

```
:PlugInstall
```

### Solarized

I used to neglect aesthetical aspects, but readibility do impact my productivity. That’s why I always install the Solarized colors theme. With Solarized my code is always readable whatever the ambient light.

Summon the plugin in `~/.vimrc` as usual:

```
Plug 'altercation/vim-colors-solarized'
```

Then add some extra config:

```
let g:solarized_contrast="high"                                 "vim-colors-solarized
set background=dark
colorscheme solarized                                           "vim-colors-solorized
```

This will configure high contast solarazid colorscheme with a dark background.

At this point, you might feel tired of typing the same `PlugInstall` command, again and again. No problem, let’s use vim automation power, adding the following line to `~/.vimrc`:

```
" reloads .vimrc -- making all changes active
map <silent> <Leader>v :source ~/.vimrc<CR>:PlugInstall<CR>:bdelete<CR>:exe ":echo 'vimrc reloaded'"<CR>
```

Save and relaunch vim for the last time. From now on `,v` will automatically reload your `~/.vimrc` and install the pluging.

### Lightline

To get the most of your screen estate, let’s improve the vim status line. There are several plugins existing to do so: Powerline, Airline and Lightline.

I’ve used them all, and I currently use Lightline because it is minimalist and does not rely on other plugins implementation.

The plugin invocation in ~/.vimrc:

```
Plug 'itchyny/lightline.vim'
```

The basic configuration:

```
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline

let g:lightline = { 'colorscheme': 'solarized', }               "vim-lightline
set laststatus=2                                                "vim-lightline
set noshowmode                                                  "vim-lightline
```

The first line bind the solarized colorscheme to the status line. Setting ‘laststatus’ to 2 ensure that the satus line is always visible. The ‘noshowmode’ remove the vim mode information line, as it’s displayed in status line.

Don’t forget to type `,v` and show your pride as the status line appears.

### Polyglot

Syntax highlighting is a must have in any decent code editor. And while vim has it built in, Polyglot brings all the latest syntax/indent pack for tons of languages and load them on demand.

If you use one or more language plugin in vim, save you some time and switch to Polyglot.

All you have to do is to add the plugin line to `~/.vimrc`

```
Plug 'sheerun/vim-polyglot'
```

And then reload/reinstall thourgh `,v`

### Editorconfig

More and more projects use [.editorconfig](http://EditorConfig.org) file to defines the indent/format rules.

Make your vim aware of this file by adding the right plugin to your `~/.vimrc`

```
Plug 'editorconfig/editorconfig-vim'
```

If you want an example of such .editorconfig for your project, here’s mine:

```
# EditorConfig is awesome: http://EditorConfig.org

# top-most EditorConfig file
root = true

# Unix-style newlines with a newline ending every file
[*]
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 4
charset = utf-8

[*.{js,json}]
indent_size = 2

[*.sql]
indent_size = 8
```

If your Vim isn’t compiled with python support (like mine) you’ll have to install and use an external editorconfig program.

```
let g:EditorConfig_core_mode = 'external_command'               "editorconfig-vim
```

From now on, I assume you know you have to type `,v` to have the new plugin installed.

### Syntastic

Ah Syntastic, this one would probably require an article on its onw. In a nutshell, Syntastic is a syntax checking plugin which handles an awfully long list of languages.

The line to add to your `~/.vimrc`

```
Plug 'vim-syntastic/syntastic'
```

Syntastic works great out of the box. Here is the recommended default configuration:

```vim
set statusline+=%#warningmsg#                                   "syntastic
set statusline+=%{SyntasticStatuslineFlag()}                    "syntastic
set statusline+=%*                                              "syntastic

let g:syntastic_always_populate_loc_list = 1                    "syntastic
let g:syntastic_auto_loc_list = 1                               "syntastic
let g:syntastic_check_on_open = 1                               "syntastic
let g:syntastic_check_on_wq = 0                                 "syntastic
```

But you can add custom checkers for your language, for example for JavaScript:

```
let g:syntastic_javascript_checkers = ['eslint']                "syntastic
```

You will have to install eslint and configure it through an .eslintrc file, which usually boils donw to something like that:

```
{
    "extends": "eslint-config-airbnb-base"
}
```

This will configure Syntastic to use eslint with airbnb coding style, but you can define custom rules in your eslintrc, and/or use another preset configuration (from [Facebook](https://www.npmjs.com/package/eslint-config-fbjs), [Google](https://github.com/google/eslint-config-google), [Canonical](https://github.com/gajus/eslint-config-canonical)…)

### Tabular

Whenever you need to align equal signs, comment signs at the end of the line, or work with table in text mode, Tabular will save your time. Don’t even try to understand this cryptic sentence (sorry) and have a look at [this screencast](http://vimcasts.org/episodes/aligning-text-with-tabular-vim/).

Interested ? Add the plugin to your `~/.vimrc`:

```
Plug 'godlygeek/tabular'
```

To gain some additional time, some configuration to match the most common use cases.

```
vnoremap <silent> <Leader>cee    :Tabularize /=<CR>              "tabular
vnoremap <silent> <Leader>cet    :Tabularize /#<CR>              "tabular
vnoremap <silent> <Leader>ce     :Tabularize /
```

‘,cee’ will Tabularize the selected lines on ‘=’ sign 
‘,cet’ will Tabularize the selected lines on ‘#’ sign 
‘,ce’ will Tabularize the selected lines on the pattern you’ll enter. This could be ‘,’ ‘|’ or more complex pattern ‘:\zs’ (try this on JSON)

### Others Plugin ?

This article is already way longer than it was supposed to be, and remember that our initial objective was simplicity. We already have more than enough for a good start, so I’ll stop to add Plugins.

But if you’re curious, I’d advise you to try the following Plugin that I used and enjoyed:

* [ack — grep on steroid](https://github.com/mileszs/ack.vim)

* [gitgutter — git diff information in a gutter](https://github.com/airblade/vim-gitgutter)

* [signify — like gitgutter for several SCM](https://github.com/mhinz/vim-signify)

* [surround — handle surrounding (quotes, brackets, tags…](https://github.com/tpope/vim-surround))

* [Fugitive — a git wrapper](https://github.com/tpope/vim-fugitive)

Or may be the following, which seem interesting and that I’m still waiting to evaluate:

* [ale — an asynchronouse lint engine](https://github.com/w0rp/ale)

* [ag — the python faster alternative to ack](https://github.com/rking/ag.vim)

* [easy-align — Tabular alternative](https://github.com/junegunn/vim-easy-align)

* [easytags — automated ctags generation](https://github.com/xolox/vim-easytags)

* [emmet — HTML/CSS processor](https://github.com/mattn/emmet-vim)

* [gitv — gitk for vim](https://github.com/gregsexton/gitv)

* [gv — a git commit browser](https://github.com/junegunn/gv.vim)

* [node — easy access to node modules](https://github.com/moll/vim-node)

* [tern — javascript editing support](https://github.com/ternjs/tern_for_vim)

### General configuration

Besides plugins, vim offers a many options to configure its behaviour.

Here are some of those that suits my way of working.

To make backspace work the way I want:

```
" make backspaces delete sensibly
set backspace=indent,eol,start
```

To autosave buffer when switching between buffer:

```
set autowrite
```

To configure how the ‘invisible’ characters should be displayed:

```
set listchars=tab:>.,trail:.,extends:#,nbsp:.
```

To ignore the case when the search pattern is all lowercase:

```
set smartcase
set ignorecase
```

To stop spiting vim backup/swap files all over the filesystem:

```vim
set backupdir=~/.vim/tmp/                   "for backup files
set directory=~/.vim/tmp/                   "for swap files
```

This will create those file in a .vim/tmp directory (don’t forget to create it)

For good measure, let’s also reconfigure some keys:

```
inoremap jj <ESC>
```

With Vim keeping your hands on the homerow is key to performance, but vim requires frequent use of the escape key. With this mapping, typing `jj` in insert mode will switch to command mode.

```
map <CR> o<Esc>k
```

I’ve realized lately that I often have to add extra line in command mode. Now the enter key in command mode just do that.

```
map <F1> <Esc>
imap <F1> <Esc>
```

On my laptop, `F1` key was really misplaced and I was constanlty hitting it instead of `<Esc>`. As I don’t use `F1` that often, I just reconfigure it to escape.

```
cmap w!! %!sudo tee > /dev/null %
```

I can’t count how many times this one saved my life. When you edit a file, and realize when you want to save that you don’t have the right, just type `:w!!` (notice the double !) and you’ll be allowed to sudo to write the file.

### Conclusion

I hope you enjoyed this article, and that you learned some new things to test. If enough people are interested, I will put the .vimrc online. As always, if you have questions/advices/criticisms don’t hesitate to leave a comment or drop me an email to arhuman (at) gmail (dot) com.

*If you liked this article you might also enjoy [the one about macros](https://medium.com/@arhuman/just-enough-macros-9505acf01f83).*
