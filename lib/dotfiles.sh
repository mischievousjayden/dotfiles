#!/bin/bash
# Shared helpers for the *_init.sh scripts. Source it, don't run it:
#
#   . "$(dirname "${BASH_SOURCE[0]}")/../lib/dotfiles.sh"
#
# Everything here is built around one idea: a symlink pointing INTO this repo is
# ours to replace, and anything else in the way belongs to the user and gets
# backed up rather than clobbered. That distinction is what makes re-running an
# init script a no-op instead of a pile of .backup files.

set -u

# Repo root, derived from this file's own location — so the callers work no
# matter which directory they were invoked from.
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- predicates -------------------------------------------------------------

# True when $1 is a symlink we created, i.e. it points inside this repo.
is_ours() {
  local target="$1" dest
  [ -L "$target" ] || return 1
  dest="$(readlink "$target")"
  case "$dest" in "$DOTFILES_ROOT"/*) return 0 ;; *) return 1 ;; esac
}

# --- install ----------------------------------------------------------------

# Clear the way for a new link. Ours is removed silently; anything else — a real
# file, a directory, a link to somewhere else — is preserved as <name>.backup.
# Note the -L test comes first: a symlink must be moved as a link, not followed.
backup() {
  local target="$1"
  if is_ours "$target"; then
    rm "$target"
  elif [ -L "$target" ] || [ -e "$target" ]; then
    mv "$target" "$target.backup"
    echo "  backed up: $(tilde "$target") -> $(tilde "$target").backup"
  fi
}

# link <src> <dst>
# Only the PARENT of dst is created. Creating dst itself would make ln place the
# link inside it (dst/src) instead of at dst — the bug this replaces.
link() {
  local src="$1" dst="$2"
  # Already pointing where we want — say nothing changed, so a re-run reads as
  # the no-op it is instead of looking like it rewrote everything.
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  unchanged: $(tilde "$dst")"
    return
  fi
  backup "$dst"
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "  linked:    $(tilde "$dst") -> $(tilde "$src")"
}

# copy <src> <dst>
# For files the tool rewrites at runtime, where a symlink would let it edit the
# repo. Identical content is left alone so re-running never overwrites an
# earlier .backup that holds the user's changes.
copy() {
  local src="$1" dst="$2"
  if cmp -s "$src" "$dst"; then
    echo "  unchanged: $(tilde "$dst")"
    return
  fi
  backup "$dst"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "  copied:    $(tilde "$dst") <- $(tilde "$src")"
}

# --- uninstall --------------------------------------------------------------

# unlink <dst>
# Remove dst only if it is a link we created. A real file the user put there, or
# a link to somewhere else, is left alone — uninstalling must never delete
# something this repo didn't install.
unlink() {
  local dst="$1"
  if is_ours "$dst"; then
    rm "$dst"
    echo "  removed:   $(tilde "$dst")"
  elif [ -L "$dst" ] || [ -e "$dst" ]; then
    echo "  kept:      $(tilde "$dst") (not ours)"
  fi
}

# unlink_all <root> [depth]
# Remove every symlink under <root> pointing into this repo. Only for a root
# this repo owns outright (e.g. ~/.claude) — in a shared directory like $HOME it
# would delete other tools' links too, so those scripts enumerate instead.
unlink_all() {
  local root="$1" depth="${2:-1}" target
  [ -d "$root" ] || return 0
  while IFS= read -r target; do
    rm "$target"
    echo "  removed:   $(tilde "$target")"
  done < <(find "$root" -maxdepth "$depth" -type l -lname "$DOTFILES_ROOT/*" 2>/dev/null)
}

# --- link tables ------------------------------------------------------------
#
# A script declares its links ONCE as "src|dst" entries, then both modes walk
# the same table. Install and uninstall cannot drift apart, because there is
# only one list.
#
#   LINKS=( "$HERE/bashrc|$HOME/.bashrc" ... )
#   run_links "$MODE"

run_links() {
  local mode="$1" entry src dst
  for entry in "${LINKS[@]}"; do
    src="${entry%%|*}"
    dst="${entry#*|}"
    if [ "$mode" = uninstall ]; then unlink "$dst"; else link "$src" "$dst"; fi
  done
}

# --- misc -------------------------------------------------------------------

# Shorten $HOME to ~ so output stays readable. The replacement goes through a
# variable because a literal ~ inside ${...} would come out backslash-escaped.
tilde() { local t='~'; printf '%s' "${1/#$HOME/$t}"; }

# Sets MODE to install|uninstall. Call it directly, not via $(...) — the exit on
# a bad argument has to terminate the script, not a subshell.
#   parse_mode "$@"
MODE=install
parse_mode() {
  case "${1:-}" in
    ""|--install|-i) MODE=install ;;
    --uninstall|-u)  MODE=uninstall ;;
    *) echo "unknown option: $1 (use --install or --uninstall)" >&2; exit 2 ;;
  esac
}
