# Global memory (Claude Code adapter)

This file is the Claude Code entry point. It holds no policy of its own — it
only pulls in the tool-neutral policy plus this machine's local additions.
Edit the policy in `ai-agents/shared/AGENTS.md`, not here.

## Shared policy

@~/.claude/shared/AGENTS.md

## Claude-specific enforcement

`PreToolUse` hooks make parts of the shared policy hard blocks rather than
suggestions:

- `~/.claude/hooks/block-host-installs.sh` — denies host package installs,
  including project-local `npm install`. A command whose first word is a
  container runtime (`podman`/`docker`/`nerdctl`) passes through. The deny
  message names whichever runtime this machine actually has.
- `~/.claude/hooks/block-master-write.sh` — denies `git commit` on the
  repository's default branch and `git push` targeting it. `master` and `main`
  are always protected too.
- `~/.claude/hooks/block-agent-attribution.sh` — denies commits and PR/MR text
  that credit an AI assistant. It matches attribution constructs, not tool
  names, so a commit *about* Claude Code still goes through.

So don't reach for `pip install` "just to see if it works" — it will be denied.
Go straight to a container. And if an install truly has to happen on the host,
hand the exact command to the user as described in the shared policy instead of
trying to slip it past the hook.

## Machine-local extensions

@~/.dotfiles_local/ai-agents/index.md
