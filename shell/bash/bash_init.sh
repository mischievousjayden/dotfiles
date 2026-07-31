#!/bin/bash
# Links the bash config into $HOME.
#   ./bash_init.sh              install
#   ./bash_init.sh --uninstall  remove the links this script created

. "$(dirname "${BASH_SOURCE[0]}")/../../lib/dotfiles.sh"
parse_mode "$@"

HERE="$DOTFILES_ROOT/shell/bash"
COMMON="$DOTFILES_ROOT/shell/common"

LINKS=(
  "$HERE/bashrc|$HOME/.bashrc"
  "$COMMON/common_function|$HOME/.bash_function"
  "$COMMON/common_alias|$HOME/.bash_alias"
)

echo "bash ($MODE):"
run_links "$MODE"
