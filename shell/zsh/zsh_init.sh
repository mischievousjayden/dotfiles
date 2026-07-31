#!/bin/bash
# Links the zsh config into $ZDOTDIR (or $HOME).
#   ./zsh_init.sh              install
#   ./zsh_init.sh --uninstall  remove the links this script created
#
# Runs under bash, not zsh — nothing here needs zsh, and the shared helpers use
# BASH_SOURCE to locate the repo. $ZDOTDIR is still honoured when it is exported.

. "$(dirname "${BASH_SOURCE[0]}")/../../lib/dotfiles.sh"
parse_mode "$@"

HERE="$DOTFILES_ROOT/shell/zsh"
COMMON="$DOTFILES_ROOT/shell/common"
ZDOT="${ZDOTDIR:-$HOME}"

LINKS=(
  "$HERE/zshrc|$ZDOT/.zshrc"
  "$COMMON/common_function|$ZDOT/.zsh_function"
  "$COMMON/common_alias|$ZDOT/.zsh_alias"
)

echo "zsh ($MODE):"
run_links "$MODE"
