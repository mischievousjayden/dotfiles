#!/bin/bash

# link config for vim
VIM_CONFIG_PACK_DIR="$HOME"/.vim/pack
[ -f "$VIM_CONFIG_PACK_DIR" ] && mv "$VIM_CONFIG_PACK_DIR" "$VIM_CONFIG_PACK_DIR".backup
[ ! -d "$VIM_CONFIG_PACK_DIR" ] && mkdir -p "$VIM_CONFIG_PACK_DIR"
ln -s "$PWD"/pack "$VIM_CONFIG_PACK_DIR"

# link config for nvim
NVIM_CONFIG_PACK_DIR="$HOME"/.config/nvim/pack
[ -f "$NVIM_CONFIG_PACK_DIR" ] && mv "$NVIM_CONFIG_PACK_DIR" "$NVIM_CONFIG_PACK_DIR".backup
[ ! -d "$NVIM_CONFIG_PACK_DIR" ] && mkdir -p "$NVIM_CONFIG_PACK_DIR"
ln -s "$PWD"/pack "$NVIM_CONFIG_PACK_DIR"

# link vimrc
VIMRC_FILE="$HOME"/.vimrc
[ -f "$VIMRC_FILE" ] && mv "$VIMRC_FILE" "$VIMRC_FILE".backup
ln -s "$PWD"/vimrc "$VIMRC_FILE"

# install submodules
if command -v git &>/dev/null; then
    git submodule update --init --recursive
else
    echo "git not found — can't pull submodules"
fi
