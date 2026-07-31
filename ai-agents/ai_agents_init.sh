#!/bin/bash
# Mirrors the vim_init.sh / tmux_init.sh pattern: back up whatever is already
# there, then symlink this repo's files into place.
# Run from this directory:  cd <dotfiles>/ai-agents && ./ai_agents_init.sh
#
# Layout:
#   shared/   tool-neutral content (policy + Agent Skills) — reused by every tool
#   claude/   Claude Code adapter — loads shared/ using Claude's own syntax
#
# Only Claude Code is installed on this machine today, so it is the only adapter
# here. Adding another tool later = add its base dir to TOOL_DIRS (for skills)
# and write a small <tool>_adapter function below.

set -u

REPO_DIR="$PWD"
SHARED_DIR="$REPO_DIR/shared"
SKILLS_DIR="$SHARED_DIR/skills"
LOCAL_DIR="$HOME/.dotfiles_local/ai-agents"

# Agent tools that read personal skills from <base>/skills/, following the open
# Agent Skills standard (https://agentskills.io): one skill = one folder holding
# a SKILL.md. A tool is only touched if its base dir already exists — i.e. the
# tool is installed — so uninstalled tools are skipped instead of littering ~.
TOOL_DIRS=(
  "$HOME/.claude"   # Claude Code
)

# --- helpers ----------------------------------------------------------------

# True when $1 is a symlink we previously created (points inside this repo).
# Those are replaced silently on re-run; anything else gets backed up.
is_ours() {
  local target="$1" dest
  [ -L "$target" ] || return 1
  dest="$(readlink "$target")"
  case "$dest" in "$REPO_DIR"/*) return 0 ;; *) return 1 ;; esac
}

backup() {
  local target="$1"
  if is_ours "$target"; then
    rm "$target"
  elif [ -L "$target" ] || [ -e "$target" ]; then
    mv "$target" "$target.backup"
    echo "  backed up: $target -> $target.backup"
  fi
}

link() {
  local src="$1" dst="$2"
  backup "$dst"
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "  linked:    $dst -> $src"
}

# settings.json and friends are rewritten by the agent at runtime (permission
# prompts, /config). Symlinking them would let the tool edit the repo behind our
# back, so those are copied instead — re-run this script to push repo changes.
copy() {
  local src="$1" dst="$2"
  # Already in sync — do nothing, so re-running never clobbers an earlier
  # .backup holding changes the app made.
  if cmp -s "$src" "$dst"; then
    echo "  unchanged: $dst"
    return
  fi
  backup "$dst"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "  copied:    $dst <- $src"
}

# --- Claude Code adapter ----------------------------------------------------

claude_adapter() {
  local base="$HOME/.claude" config="$REPO_DIR/claude"

  echo "Claude Code ($base):"
  if [ ! -d "$base" ]; then
    echo "  not installed — skipped"
    return
  fi

  # Global memory entry point + the shared policy it @imports.
  link "$config/CLAUDE.md" "$base/CLAUDE.md"
  link "$SHARED_DIR/AGENTS.md" "$base/shared/AGENTS.md"

  # PreToolUse hooks — Claude Code is the only tool here that can hard-block.
  local hook
  for hook in "$config"/hooks/*.sh; do
    [ -f "$hook" ] || continue
    chmod +x "$hook"
    link "$hook" "$base/hooks/$(basename "$hook")"
  done

  # Runtime-mutable file — copy, don't link.
  [ -f "$config/settings.json" ] && copy "$config/settings.json" "$base/settings.json"
}

# --- run --------------------------------------------------------------------

claude_adapter

# Portable Agent Skills — one folder linked into every installed tool.
echo ""
echo "Agent Skills (shared/skills/ -> <tool>/skills/):"
if [ -d "$SKILLS_DIR" ]; then
  shopt -s nullglob
  skills=("$SKILLS_DIR"/*/)
  shopt -u nullglob
  if [ ${#skills[@]} -eq 0 ]; then
    echo "  (no skills in shared/skills/ yet)"
  fi
  # <tool>/skills/ is a FLAT namespace shared by every source that links into it
  # — this repo, a team hub (e.g. elements/agents), personal folders. So never
  # take over a name we don't own: refresh our own links, warn and skip anything
  # else. Same rule the team's link-skills.sh follows, so the two can coexist.
  for skill in "${skills[@]}"; do
    src="${skill%/}"
    name="$(basename "$src")"
    for base in "${TOOL_DIRS[@]}"; do
      [ -d "$base" ] || continue
      dest="$base/skills/$name"
      if is_ours "$dest"; then
        rm "$dest"
        ln -s "$src" "$dest"
        echo "  refreshed: $dest"
      elif [ -L "$dest" ]; then
        echo "  SKIPPED:   $dest already points elsewhere:" >&2
        echo "             $(readlink "$dest")" >&2
        echo "             Rename one of the colliding skills, or remove the link and re-run." >&2
      elif [ -e "$dest" ]; then
        echo "  SKIPPED:   $dest exists and is not a symlink (personal skill?)." >&2
      else
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
        echo "  linked:    $dest -> $src"
      fi
    done
  done
else
  echo "  (no shared/skills/ directory yet)"
fi

# Machine-local additions: anything dropped into ~/.dotfiles_local/ai-agents/ is
# collected into an index the adapters import. Keeps work-machine-only or
# secret-ish context out of this repo.
echo ""
echo "Machine-local index ($LOCAL_DIR/index.md):"
mkdir -p "$LOCAL_DIR"
INDEX="$LOCAL_DIR/index.md"

{
  echo "# Machine-local agent memory index"
  echo "# Auto-generated by ai_agents_init.sh — DO NOT EDIT BY HAND."
  echo "# Drop any *.md into $LOCAL_DIR/ and re-run ai_agents_init.sh."
  echo ""
  found=0
  for f in "$LOCAL_DIR"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "index.md" ] && continue
    echo "@$f"
    found=$((found + 1))
  done
  if [ "$found" -eq 0 ]; then
    echo "# (no machine-local .md files yet)"
  fi
} > "$INDEX"

count=$(grep -c '^@' "$INDEX" || true)
echo "  regenerated with $count import(s)"

echo ""
echo "Done."
