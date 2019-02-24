#!/bin/bash

# link config
[ -f "$HOME"/.tmux.conf ] && mv "$HOME"/.tmux.conf "$HOME"/.tmux.conf.backup
ln -s $PWD/tmux.conf $HOME/.tmux.conf

