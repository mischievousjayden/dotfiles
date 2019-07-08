#!/bin/bash

# link config
[ -f "$HOME"/.bashrc ] && mv "$HOME"/.bashrc "$HOME"/.bashrc.backup
ln -s "$PWD"/bashrc ~/.bashrc

[ -f "$HOME"/.bash_aliases ] && mv "$HOME"/.bash_aliases "$HOME"/.bash_aliases.backup
ln -s "$PWD"/bash_aliases ~/.bash_aliases

