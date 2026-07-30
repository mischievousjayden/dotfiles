#!/usr/bin/env bash
# Blocks AI attribution from landing in git history or PR/MR text.
#
# Scope is deliberately narrow. It matches ATTRIBUTION patterns — trailers,
# "Generated with" footers, the robot byline — NOT mentions of a tool's name.
# A commit that legitimately discusses Claude Code (say, one that configures it)
# must still be committable, so 'Claude' on its own is never a trigger.
#
# Covers the paths where the text is visible from the command line:
#   git commit -m/--message, git commit -F/--file <path>
#   git tag -m/--message
#   gh pr create|edit --title/--body/--body-file
#   glab mr create|update --title/--description
# A message typed into $EDITOR is invisible here; the shared policy still applies.

set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# Only inspect commands that actually write history or PR/MR text.
printf '%s' "$cmd" | grep -qE '\b(git[[:space:]]+(commit|tag)|gh[[:space:]]+(pr|release)|glab[[:space:]]+mr)\b' || exit 0

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

# Attribution markers. Vendor names only count next to a crediting construct.
AI='claude|anthropic|openai|chatgpt|gpt-[0-9]|copilot|codex|cursor|gemini|devin'
patterns=(
  "(co-authored|assisted|generated|authored|created|signed-off)-by:[^\n]*($AI)"
  "generated[[:space:]]+with[[:space:]]+[^\n]*($AI)"
  "(written|generated|created|produced)[[:space:]]+by[[:space:]]+($AI)"
  "noreply@anthropic\.com"
  "🤖"
)

scan() { # $1 = text, $2 = where it came from
  local text="$1" where="$2" p
  for p in "${patterns[@]}"; do
    if printf '%s' "$text" | grep -qiE "$p"; then
      deny "Blocked: AI attribution in $where.

Matched: $(printf '%s' "$text" | grep -ioE "$p" | head -1)

Git history and PR/MR text must contain no reference crediting an AI assistant:
no 'Co-Authored-By:' trailer naming one, no 'Generated with ...' footer, no
robot byline, no assistant address. Write the message as the author would —
what changed and why.

Naming a tool as the SUBJECT of the work is fine ('configure Claude Code
hooks'); crediting it as an AUTHOR is not. Remove the trailer and retry."
    fi
  done
}

scan "$cmd" "the command"

# Message/body passed by file — read it and scan the contents too.
set -f
prev=""
for word in $cmd; do
  path=""
  case "$word" in
    -F=*|--file=*|--body-file=*) path="${word#*=}" ;;
    *) case "$prev" in -F|--file|--body-file) path="$word" ;; esac ;;
  esac
  prev="$word"
  [ -z "$path" ] && continue
  [ "$path" = "-" ] && continue          # stdin — not inspectable
  path="${path%\"}"; path="${path#\"}"; path="${path%\'}"; path="${path#\'}"
  if [ -r "$path" ]; then
    set +f
    scan "$(cat "$path")" "$path"
    set -f
  fi
done
set +f

exit 0
