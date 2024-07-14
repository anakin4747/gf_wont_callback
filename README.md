# A Neovim plugin for a smarter `gf` goto file

## Description

## Demonstration

## Features

- Aware of the $PWD of a terminal buffer
- Expands environment variables and `~` in <cfile>
- Works with relative and absolute filepaths
- Will search $PWD for a filename
- Will search $PWD for partial filepaths and provide a quickfix menu if it
  finds multiple options

## Bugs

When you are hovering over the word Makefile and if you are in folder1 and want
to open folder1/folder2/Makefile but there is a folder1/Makefile it will open
that instead

