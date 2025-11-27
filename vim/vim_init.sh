#!/bin/bash

# link config for vim
VIM_CONFIG_PACK_DIR="$HOME"/.vim/pack
[ -f "$VIM_CONFIG_PACK_DIR" ] && mv "$VIM_CONFIG_PACK_DIR" "$VIM_CONFIG_PACK_DIR".backup
ln -s "$PWD"/pack "$VIM_CONFIG_DIR"

# link config for nvim
NVIM_CONFIG_PACK_DIR="$HOME"/.config/nvim/pack
[ -f "$NVIM_CONFIG_PACK_DIR" ] && mv "$NVIM_CONFIG_PACK_DIR" "$NVIM_CONFIG_PACK_DIR".backup
ln -s "$PWD"/pack "$NVIM_CONFIG_DIR"

# link vimrc
VIMRC_FILE="$HOME"/.vimrc
[ -f "$VIMRC_FILE" ] && mv "$VIMRC_FILE" "$VIMRC_FILE".backup
ln -s "$PWD"/vimrc "$VIMRC_FILE"

# install vim bundle 
git submodule update --init --recursive

