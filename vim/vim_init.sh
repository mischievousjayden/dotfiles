#!/bin/bash

# link config for vim
VIM_CONFIG_PACK_DIR="$HOME"/.vim/pack
[ -f "$VIM_CONFIG_PACK_DIR" ] && mv "$VIM_CONFIG_PACK_DIR" "$VIM_CONFIG_PACK_DIR".backup
[ ! -d "$VIM_CONFIG_PACK_DIR" ] && mkdir -p "$VIM_CONFIG_PACK_DIR"
ln -s "$PWD"/pack "$VIM_CONFIG_PACK_DIR"

# link vimrc
VIMRC_FILE="$HOME"/.vimrc
[ -f "$VIMRC_FILE" ] && mv "$VIMRC_FILE" "$VIMRC_FILE".backup
ln -s "$PWD"/vimrc "$VIMRC_FILE"

if command -v nvim &>/dev/null; then
    NVIM_CONFIG_DIR="$HOME"/.config/nvim
    [ ! -d "$NVIM_CONFIG_DIR" ] && mkdir -p "$NVIM_CONFIG_DIR"

    # link config for nvim
    NVIM_CONFIG_PACK_DIR="$NVIM_CONFIG_DIR"/pack
    [ -f "$NVIM_CONFIG_PACK_DIR" ] && mv "$NVIM_CONFIG_PACK_DIR" "$NVIM_CONFIG_PACK_DIR".backup
    ln -s "$PWD"/pack "$NVIM_CONFIG_PACK_DIR"

    # # link nvimrc
    # NVIMRC_FILE="$NVIM_CONFIG_DIR"/init.vim
    # [ -f "$NVIMRC_FILE" ] && mv "$NVIMRC_FILE" "$NVIMRC_FILE".backup
    # ln -s "$PWD"/nvimrc "$NVIMRC_FILE"
else
    echo "nvim not found — skip nvim config"
fi

# install submodules
if command -v git &>/dev/null; then
    git submodule update --init --recursive
else
    echo "git not found — can't pull submodules"
fi
