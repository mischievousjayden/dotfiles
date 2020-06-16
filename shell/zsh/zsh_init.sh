#!/bin/zsh

[ -f "${ZDOTDIR:-$HOME}"/.zshrc ] && mv "${ZDOTDIR:-$HOME}"/.zshrc "${ZDOTDIR:-$HOME}"/.zshrc.backup
ln -s "$PWD"/zshrc "${ZDOTDIR:-$HOME}"/.zshrc

[ -f "${ZDOTDIR:-$HOME}"/.zsh_function ] && mv "${ZDOTDIR:-$HOME}"/.zsh_function "${ZDOTDIR:-$HOME}"/.zsh_function.backup
ln -s "$PWD"/../common/common_function "${ZDOTDIR:-$HOME}"/.zsh_function

[ -f "${ZDOTDIR:-$HOME}"/.zsh_alias ] && mv "${ZDOTDIR:-$HOME}"/.zsh_alias "${ZDOTDIR:-$HOME}"/.zsh_alias.backup
ln -s "$PWD"/../common/common_alias "${ZDOTDIR:-$HOME}"/.zsh_alias

