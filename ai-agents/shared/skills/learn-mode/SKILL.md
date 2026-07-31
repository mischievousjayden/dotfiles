---
name: learn-mode
description: >-
  Work on a task in "learning mode" — produce a structured report capturing
  hypotheses/approaches, tool reasoning, post-mortem, and alternative paths so
  the user can study the process and ask questions. Use when the user invokes
  /learn-mode, says "learn mode", "teach me while doing", or otherwise signals
  they want to learn from how the work is done (not just receive the result).
  Adapts to task type: debugging, design, exploration, refactoring, or general
  implementation.
---

# Learning Mode

The user is doing this task **partly to learn** from how you approach it. Produce a reviewable, structured report alongside doing the work — do not just deliver a result.

Match the user's conversation language for all report content (headings can stay English; prose, reasoning, and post-mortem should follow whatever language the user is writing in).

## Setup

### Step 1 — Identify task type
From the user's prompt, classify into one of:
- **debug** — fixing a bug or investigating broken behavior
- **design** — planning architecture, API, or new feature
- **explore** — understanding unfamiliar code/systems
- **refactor** — restructuring existing code
- **task** — general implementation or operation

If unclear, ask the user briefly which fits.

### Step 2 — Create the report file
Path: `~/.learn-logs/YYYY-MM-DD-<short-slug>.md`

- Slug: 3-5 kebab-case words derived from the task
- If the directory doesn't exist, create it (`mkdir -p ~/.learn-logs`)
- If a file with the same slug already exists today, append `-2`, `-3`, etc.

Header template:
```
# Learning Log: <task title>
- **Date:** YYYY-MM-DD
- **Type:** <debug | design | explore | refactor | task>
- **Goal:** <one-sentence goal>
```

Update this file incrementally as you work — do not wait until the end.

## During the work

For EVERY meaningful step, append a section to the report. A "meaningful step" is any of:
- Forming or changing a hypothesis (debug) / approach (design) / theory (explore)
- Running a non-trivial tool or command
- Reading a file to find specific information
- Making a design decision or rejecting one

### Step template
```
## Step N: <short title>
**Hypothesis / Approach:** what you think is going on, or what you're about to try
**Why:** the evidence or reasoning behind this
**Tool / Action:** `<command or action>`
  - **Why this tool:** vs. alternatives (X, Y)
  - **Flags:** what non-obvious flags mean
**Result:** brief summary of what you found
**Update:** how this changes your thinking — confirmed / rejected / refined?
```

Keep each field tight (1-3 sentences). The user is reading this to LEARN — reasoning matters more than completeness of output dump.

## Tool narration rules

Whenever you use a tool, briefly note in the report:
- **Why this tool** vs. alternatives
- **Category** (search / git archaeology / runtime inspection / static analysis / log analysis / etc.)
- **Non-obvious flags** if any

Example:
> `rg "TokenError" --type ts` — ripgrep (search category). Chose over `grep -r` (slower, no gitignore) and `ast-grep` (overkill for plain string match). `--type ts` filters to TypeScript files, excluding generated JS and `.d.ts` artifacts.

## Required closing sections — ALWAYS produce these

### Outcome
```
## Outcome
- **What was done:** ...
- **Location:** file:line references
- **Pending:** anything not yet applied
```

Task-type adaptation:
- **debug** — include root cause
- **design** — include final decision and tradeoffs accepted
- **explore** — include the mental model arrived at
- **refactor** — include diff summary
- **task** — include what shipped and what's left

### Post-Mortem (Learning Section)
```
## Post-Mortem
- **Decisive moment:** what evidence/insight cracked the problem
- **Wrong turns:** hypotheses/approaches rejected and why they seemed plausible at first
- **Class of problem:** what category is this, and what to watch for next time
- **Tools introduced:** any non-obvious tool used today, with a one-line reference card
```

### Alternative Paths
```
## Alternative Paths
- **Path A:** how this could have been approached differently — pros/cons
- **Path B:** another approach — pros/cons
- (2-3 total; for debug, these are alternative debugging strategies; for design, alternative architectures)
```

## Handoff and review

After producing the full report, message the user:

> Learning log at `<absolute path>`. Review it and ask any questions before I apply changes / move on.

**DO NOT** apply significant or destructive changes until the user has reviewed. For debug tasks, do not apply the fix until reviewed. For design tasks, do not start implementing.

For pure exploration tasks (no changes needed), the report itself is the deliverable.

## Handling user questions during review

When the user asks a question about the report:
1. Answer it clearly in chat.
2. ALSO append the clarification to the relevant section of the report under a Q/A sub-bullet:
   ```
   - **Q:** <user's question>
   - **A:** <your answer>
   ```
3. This keeps the log complete as a future learning reference.

## Tone

Patient, teacherly. Prefer **clarity** over brevity in REASONING sections. Stay terse in commands and result summaries — readability of the log is what matters, not exhaustive output dumps.

## Do NOT

- Skip the post-mortem or alternative-paths sections, even if the task was easy. The "easy" framing is itself a learning point.
- Apply changes silently before the user reviews the report.
- Dump full file contents or full tool outputs into the log — summarize. The user can ask to see specifics.
- Use this mode for trivial one-liners (renames, typo fixes). If the task wouldn't teach anything, say so and offer to proceed normally.
