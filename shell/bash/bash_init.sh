#!/bin/bash

[ -f "$HOME"/.bashrc ] && mv "$HOME"/.bashrc "$HOME"/.bashrc.backup
ln -s "$PWD"/bashrc ~/.bashrc

[ -f "$HOME"/.bash_function ] && mv "$HOME"/.bash_function "$HOME"/.bash_function.backup
ln -s "$PWD"/../common/common_function "$HOME"/.bash_function

[ -f "$HOME"/.bash_alias ] && mv "$HOME"/.bash_alias "$HOME"/.bash_alias.backup
ln -s "$PWD"/../common/common_alias "$HOME"/.bash_alias

