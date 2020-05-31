#!/bin/zsh

# link config
ln -s $PWD/zshrc ${ZDOTDIR:-$HOME}/.zshrc
ln -s $PWD/../common/common_alias ${ZDOTDIR:-$HOME}/.zsh_alias
ln -s $PWD/../common/common_function ${ZDOTDIR:-$HOME}/.zsh_function

