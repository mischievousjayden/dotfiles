#!/usr/bin/env bash
# Blocks host-side package installs (pip, conda, brew, apt, gem, cargo, go,
# npm/yarn/pnpm — global AND project-local, etc.). Allows commands wrapped in a
# container runtime. When an install genuinely has to run on the host, the deny
# message tells the agent to hand the command to the user rather than route
# around the guard.

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

# Allow if the WHOLE command runs through a container runtime (optionally with
# sudo). Anything inside the container is the container's business. Add runtimes
# here as needed — the policy is "a container", not "podman specifically".
KNOWN_RUNTIMES=(podman docker nerdctl)
RUNTIMES=$(IFS='|'; printf '%s' "${KNOWN_RUNTIMES[*]}")
RUNTIME_LIST=$(IFS='/'; printf '%s' "${KNOWN_RUNTIMES[*]}")
if printf '%s' "$cmd" | grep -qE "^[[:space:]]*(sudo[[:space:]]+)?($RUNTIMES)[[:space:]]"; then
  exit 0
fi

# Which runtime does THIS machine actually have? Never assume podman — dotfiles
# get cloned onto machines that only have docker. Falls back to a note when
# nothing is installed, so the message can't recommend a runtime that isn't here.
RT=""
for r in "${KNOWN_RUNTIMES[@]}"; do
  if command -v "$r" >/dev/null 2>&1; then RT="$r"; break; fi
done
if [ -n "$RT" ]; then
  rt_note="$RT is installed here; the other runtimes work the same way"
else
  RT="podman"
  rt_note="NO container runtime found on this machine — the examples below \
assume '$RT'. Say so when you hand the command over, since installing a runtime \
is itself a host change the user has to make"
fi

patterns=(
  '\b(sudo[[:space:]]+)?pip[23]?[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?pipx[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?python[23]?[[:space:]]+-m[[:space:]]+pip[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?(conda|mamba)[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?brew[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?apt(-get)?[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?(yum|dnf)[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?gem[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?cargo[[:space:]]+install\b'
  '\b(sudo[[:space:]]+)?go[[:space:]]+install\b'
  # npm/yarn/pnpm: ALL installs, not just -g. A project-local install still runs
  # arbitrary package scripts on the host.
  '\b(sudo[[:space:]]+)?npm[[:space:]]+(install|i|add|ci)\b'
  '\b(sudo[[:space:]]+)?yarn[[:space:]]+(install|add|global[[:space:]]+add)\b'
  '\b(sudo[[:space:]]+)?pnpm[[:space:]]+(install|i|add)\b'
  '\buv[[:space:]]+(pip[[:space:]]+install|tool[[:space:]]+install|add|sync)\b'
)

for p in "${patterns[@]}"; do
  if printf '%s' "$cmd" | grep -qE "$p"; then
    deny "Blocked: host installs are disabled by policy. Run it in a container.

Quick options ($rt_note):
  - One-off Python script:
      $RT run --rm -v \"\$PWD:/work\" -w /work python:3.12 python your_script.py
  - Interactive Python shell:
      $RT run --rm -it -v \"\$PWD:/work\" -w /work python:3.12 bash
  - Node project (project-local installs are blocked on the host too):
      $RT run --rm -v \"\$PWD:/work\" -w /work node:20 npm install
  - Already-running container:
      $RT exec <name> <command>

A command whose FIRST word is $RUNTIME_LIST passes through untouched.

IF THIS INSTALL GENUINELY HAS TO RUN ON THE HOST: do not work around this guard
— no script files, heredocs, eval, or variable-splitting. Stop and hand it to
the user instead:
  1. the exact command, verbatim, in its own copy-pasteable block
  2. why a container does not work for this specific case
  3. what it changes on the host (package manager, what lands where)
  4. any alternative you can see
Then let the user run it or approve it. Asking is always fine."
  fi
done

exit 0
