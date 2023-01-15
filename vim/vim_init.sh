#!/bin/bash

# link config
[ -f "$HOME"/.vim ] && mv "$HOME"/.vim "$HOME"/.vim.backup
ln -s "$PWD"/vim "$HOME"/.vim

[ -f "$HOME"/.vimrc ] && mv "$HOME"/.vimrc "$HOME"/.vimrc.backup
ln -s "$PWD"/vimrc "$HOME"/.vimrc

# install vim bundle 
git submodule update --init --recursive

