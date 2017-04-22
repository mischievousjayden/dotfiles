#!/bin/bash

# link vimrc
ln -s $PWD/vim $HOME/.vim
ln -s $PWD/vim/vimrc $HOME/.vimrc

# install pathogen
mkdir -p ~/.vim/autoload
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# install vim bundle 
git submodule update --init --recursive

# youcompleteme install
cd vim/bundle/youcompleteme && ./install.py --clang-completer --system-libclang --gocode-completer --tern-completer

