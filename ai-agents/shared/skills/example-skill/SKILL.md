---
name: example-skill
description: >-
  Starter template demonstrating the Agent Skills format. Replace this with a
  description of WHAT the skill does and WHEN an agent should use it — include
  concrete trigger words, since this is the only text an agent sees before
  deciding to load the skill.
---

# Example Skill

This is a template skill in the open [Agent Skills](https://agentskills.io)
format. A skill is just a folder with a `SKILL.md` at its root; the YAML
frontmatter above (`name` + `description`) is the only required part.

Agents use skills via **progressive disclosure**:

1. **Discovery** — only the `name` + `description` are loaded at startup.
2. **Activation** — when a task matches the description, the agent reads this
   full file into context.
3. **Execution** — the agent follows these instructions, optionally running
   bundled scripts or reading referenced files.

So write the body as instructions *to the agent*: the procedure to follow, when
to do what, and any gotchas.

Note the `description: >-` block scalar above — copy that shape. A plain
unquoted value breaks as soon as it contains `: ` (colon-space), which a strict
YAML parser reads as a nested mapping rather than text.

## Optional bundled resources

A skill can ship more than instructions. Add any of these alongside `SKILL.md`
and reference them from this file so they load only when needed:

```
example-skill/
├── SKILL.md          # this file (required)
├── scripts/          # executable helpers the agent can run
├── references/       # docs the agent reads on demand
└── assets/           # templates, fixtures, etc.
```

## How this skill is installed

`ai_agents_init.sh` symlinks this folder into the personal skills dir of every
agent tool installed on the machine (`<tool base dir>/skills/`). Nothing here is
tied to a particular client, so the same folder works with any tool that
supports the standard. Edit it once in the dotfiles repo; every tool picks up
the change.

To add your own skill: copy this folder, rename it, rewrite the frontmatter and
body, then re-run `./ai_agents_init.sh`.
