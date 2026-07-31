#!/bin/bash
# Links the vim/nvim config into $HOME and pulls the plugin submodules.
#   ./vim_init.sh              install
#   ./vim_init.sh --uninstall  remove the links this script created

. "$(dirname "${BASH_SOURCE[0]}")/../lib/dotfiles.sh"
parse_mode "$@"

HERE="$DOTFILES_ROOT/vim"
NVIM_DIR="$HOME/.config/nvim"

LINKS=(
  "$HERE/pack|$HOME/.vim/pack"
  "$HERE/vimrc|$HOME/.vimrc"
)

# nvim shares the same pack directory. Only linked when nvim is installed, but
# always listed when uninstalling so an old link is cleaned up even if nvim has
# since been removed.
if [ "$MODE" = uninstall ] || command -v nvim >/dev/null 2>&1; then
  LINKS+=( "$HERE/pack|$NVIM_DIR/pack" )
elif [ "$MODE" = install ]; then
  echo "  (nvim not found — skipping $(tilde "$NVIM_DIR"))"
fi

echo "vim ($MODE):"
run_links "$MODE"

# Plugins live in submodules; only meaningful when installing.
if [ "$MODE" = install ]; then
  if command -v git >/dev/null 2>&1; then
    git -C "$DOTFILES_ROOT" submodule update --init --recursive
  else
    echo "  git not found — can't pull submodules" >&2
  fi
fi
