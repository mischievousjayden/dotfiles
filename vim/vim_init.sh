#!/bin/bash

# link config
[ -f "$HOME"/.vim ] && mv "$HOME"/.vim "$HOME"/.vim.backup
ln -s "$PWD"/vim "$HOME"/.vim

[ -f "$HOME"/.vimrc ] && mv "$HOME"/.vimrc "$HOME"/.vimrc.backup
ln -s "$PWD"/vim/vimrc "$HOME"/.vimrc

# install pathogen
mkdir -p $HOME/.vim/autoload
curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# install vim bundle 
git submodule update --init --recursive

