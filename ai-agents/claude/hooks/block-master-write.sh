#!/usr/bin/env bash
# Blocks `git commit` on master/main and `git push` targeting master/main.
# Reads PreToolUse hook JSON from stdin; emits permissionDecision JSON on deny.

set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

current_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null; }

# This repo's default branch. Usually master/main, but don't assume — resolve it
# from origin's HEAD, then fall back to init.defaultBranch.
default_branch() {
  local b
  b=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) \
    && { printf '%s\n' "${b#origin/}"; return; }
  git config --get init.defaultBranch 2>/dev/null
}

# Protected set = the resolved default branch, plus master/main as a safety net
# for when origin/HEAD isn't set locally (common on fresh clones).
protected=$( { default_branch; echo master; echo main; } | awk 'NF && !seen[$0]++' )

is_protected() {
  local b
  for b in $protected; do [ "$1" = "$b" ] && return 0; done
  return 1
}

# `git commit ...` on a protected branch
if printf '%s' "$cmd" | grep -qE '(^|[;&|]|&&|\|\|)[[:space:]]*git[[:space:]]+commit\b'; then
  br=$(current_branch)
  if is_protected "$br"; then
    deny "Blocked: '$br' is this repository's default/protected branch — no direct commits. Create a feature branch (e.g. \`git checkout -b feature/<name>\`) and open a PR for team review."
  fi
fi

# `git push ...` targeting a protected branch
if printf '%s' "$cmd" | grep -qE '(^|[;&|]|&&|\|\|)[[:space:]]*git[[:space:]]+push\b'; then
  # Scan the args for an explicit protected ref. Compare word by word instead of
  # regex-matching branch names, which breaks on names containing . or /.
  # `HEAD:main` -> take the part after the last ':'; strip any surrounding quotes.
  set -f
  for word in $cmd; do
    ref="${word##*:}"
    ref="${ref%\"}"; ref="${ref#\"}"; ref="${ref%\'}"; ref="${ref#\'}"
    if is_protected "$ref"; then
      set +f
      deny "Blocked: '$ref' is a protected branch — cannot push to it directly. Open a PR for team review."
    fi
  done
  set +f

  # Bare `git push` while sitting on a protected branch.
  br=$(current_branch)
  if is_protected "$br"; then
    # A refspec pointing at some other remote branch is fine; a bare push is not.
    if ! printf '%s' "$cmd" | grep -qE ':[a-zA-Z0-9._/-]+'; then
      deny "Blocked: currently on '$br' (protected). Switch to a feature branch before pushing."
    fi
  fi
fi

exit 0
