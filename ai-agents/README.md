# AI agent config

Config for AI coding agents, kept tool-agnostic where the tools allow it.

```
ai-agents/
├── ai_agents_init.sh   # backup + symlink into place (same pattern as vim/tmux)
├── shared/             # tool-neutral — no single tool's syntax belongs here
│   ├── AGENTS.md       # global development policy (the actual content)
│   └── skills/         # Agent Skills — one folder per skill, each with SKILL.md
└── claude/             # Claude Code adapter — thin
    ├── CLAUDE.md       # entry point; @imports shared/AGENTS.md + local index
    ├── settings.json   # hook registration, TUI prefs
    └── hooks/          # PreToolUse guards (Claude-only capability)
```

## The one rule

**Policy content lives in `shared/`. A `<tool>/` directory only contains the
glue that makes that tool load it.** If you find yourself writing a real rule
inside `claude/`, it belongs in `shared/AGENTS.md` instead.

## What is actually portable

| Thing | Portable? | Notes |
| --- | --- | --- |
| Agent Skills (`SKILL.md`) | yes | Open standard — the same folder is linked into every tool |
| Global policy prose | yes | Plain markdown; each adapter loads it its own way |
| `@import` syntax | no | Claude-specific — lives in `claude/CLAUDE.md`, never in `shared/` |
| Hooks | no | Claude Code can hard-block tool calls; most agents cannot |
| Permissions / model / sandbox | no | Every tool has its own schema |

Only Claude Code is installed on this machine, so it is the only adapter today.
The split exists so adding a second tool is small, not so it looks tidy.

## Adding another tool

1. Add its base dir to `TOOL_DIRS` in `ai_agents_init.sh` (gets the skills).
2. Add a `<tool>_adapter` function that points the tool's global-instructions
   file at `shared/AGENTS.md`.
3. Put anything tool-specific under a new `<tool>/` directory.

Uninstalled tools are skipped — the script only touches a base dir that already
exists.

## Coexisting with a team skill hub

`~/.claude/skills/` is a **flat namespace shared by everything that links into
it** — this repo, any team hub (e.g. `elements/agents`, which links ~15 skills
via its own `scripts/link-skills.sh`), and personal folders you create by hand.

`ai_agents_init.sh` therefore only ever touches names it owns. A symlink
pointing at another hub, or a real folder, is **warned about and skipped** —
never backed up or replaced. `make aiagentsclean` is likewise scoped to links
that point into this repo. The team's script follows the same rule, so running
both on one machine is safe.

Skill names are the only thing that can collide, so keep them distinctive and
kebab-case.

## Machine-local additions

Anything dropped into `~/.dotfiles_local/ai-agents/*.md` gets collected into an
auto-generated `index.md` that the adapters import. Use it for work-machine-only
context you don't want in this repo. Re-run the init script after adding a file.

`~/.dotfiles_local/` is a plain directory in `$HOME`, deliberately outside this
repo and not a git repo itself — that's the point, its contents are never
committed. **`ai_agents_init.sh` creates it** (`mkdir -p`) and rewrites
`index.md` on every run, so the `@import` target always exists: the same script
deploys `CLAUDE.md` and generates what it imports, so they can't get out of
step. The one gap is deleting `~/.dotfiles_local` by hand — the import then
dangles (Claude warns, nothing fatal) until the next `make aiagentsinit`.

## Do not commit

Credentials and local state stay out of the repo: `~/.claude/.credentials.json`,
session transcripts, `history.jsonl`, `projects/`, caches, and anything holding
per-machine trusted paths.

## Install

```bash
cd ai-agents && ./ai_agents_init.sh   # or: make aiagentsinit
```

Re-running is safe. Symlinks this script created are replaced silently;
anything else found in the way is moved to `<name>.backup` first.

`settings.json` is **copied**, not symlinked, because Claude Code rewrites it at
runtime (permission prompts, `/config`) — a symlink would let it edit the repo.
The trade-off: changes made in the app do not flow back here. To keep an in-app
change, copy `~/.claude/settings.json` into `claude/settings.json` by hand.
