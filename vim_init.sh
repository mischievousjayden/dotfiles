#!/bin/bash

# link vimrc
ln -s $PWD/vim $HOME/.vim
ln -s $PWD/vim/vimrc $HOME/.vimrc

# install pathogen
mkdir -p ~/.vim/autoload
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# install vim bundle 
cd vim && git submodule update --init --recursive

# youcompleteme install
# cd vim/bundle/youcompleteme  && git submodule update --init --recursive
