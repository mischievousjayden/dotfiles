#!/bin/bash
# Links the tmux config into $HOME.
#   ./tmux_init.sh              install
#   ./tmux_init.sh --uninstall  remove the links this script created

. "$(dirname "${BASH_SOURCE[0]}")/../lib/dotfiles.sh"
parse_mode "$@"

LINKS=(
  "$DOTFILES_ROOT/tmux/tmux.conf|$HOME/.tmux.conf"
)

echo "tmux ($MODE):"
run_links "$MODE"
