# Global development policy

Tool-neutral policy shared by every AI coding agent on this machine. Keep this
file free of any single tool's syntax (no `@imports`, no tool-specific paths) —
each tool's adapter under `ai-agents/<tool>/` is responsible for loading it.

Some agents can additionally *enforce* parts of this policy (Claude Code does it
with `PreToolUse` hooks). Where a tool has no enforcement mechanism, these rules
still apply — they are just instructions rather than hard blocks.

## No host installs — use a container

Do not install packages onto the host. When work needs a dependency, run it in a
container instead.

**Any container runtime is fine** — `podman`, `docker`, `nerdctl`. These
dotfiles are used on more than one machine and they do not all have the same
one, so **check what is actually available before suggesting a command** rather
than assuming:

```bash
RUNTIME=$(command -v podman || command -v docker || command -v nerdctl)
```

The templates below use `$RUNTIME` for that reason. If no runtime is present at
all, say so — installing one is itself a host change for the user to make.

**Not allowed on the host:** `pip/pip3/pipx install`, `python -m pip install`,
`conda/mamba install`, `brew install`, `apt(-get)/yum/dnf install`,
`gem install`, `cargo install`, `go install`, `uv pip install` /
`uv tool install` / `uv add`, and **any** `npm`/`yarn`/`pnpm` install — including
project-local `npm install` without `-g`. Writing a `./node_modules` still means
running arbitrary install scripts on the host, so it belongs in a container too.

**Allowed:** any command whose first word is a container runtime, and any command
that isn't an install.

The shape is always the same — mount the working directory, run the command
inside an image, throw the container away:

```bash
$RUNTIME run --rm -v "$PWD:/work" -w /work <image> <command>
```

### When to recommend a Dockerfile vs a one-off `run`

- **One-off script, few deps** → inline `$RUNTIME run` with `pip install -r ...`
  is fine
- **Repeated work, custom deps, or non-trivial setup** → write a `Dockerfile` in
  the project, build once, then `$RUNTIME run <image>` per invocation

A `Dockerfile` is portable across runtimes — podman reads it fine. Don't write
runtime-specific tooling (compose files pinned to one engine) without asking.

### When a host install really is necessary

Sometimes the container route genuinely does not work — a tool has to see the
host filesystem, needs host hardware, or is the very thing being debugged.

**Do not work around the block.** Do not move the command into a script file, a
heredoc, `eval`, or split it across variables to get past the pattern match.
That defeats the point and hides a host change from the user.

Instead, stop and hand it over:

1. Print the **exact command**, verbatim, in its own copy-pasteable block.
2. Say **why a container doesn't work** for this specific case.
3. Say **what it changes on the host** — which package manager, what gets
   installed, and where.
4. Offer at least one **alternative** if one exists (a container variant, a
   vendored binary, a different library, doing without).

Then wait. The user reviews it and either runs it themselves or tells you to
proceed. Asking is always fine; silently routing around the guard is not.

## Never write to the repository's default branch

Do not `git commit` while on the repository's **default branch**, and do not
`git push` to it. On most repos here that is `master` or `main`, but resolve it
per repository rather than assuming:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD   # -> origin/<default>
```

`master` and `main` are always treated as protected, even when the resolved
default is something else.

Create a feature branch and open a PR for review instead. Always branch from the
**latest** default branch, not from whatever the local copy happens to be at:

```bash
git fetch origin
git checkout -b <name> origin/<default>
```

### Rebase before pushing

Before every push, check whether the parent branch has moved and rebase onto it,
so what lands on the remote is always current:

```bash
git fetch origin
git rebase origin/<default>      # or the parent branch, if it isn't the default
```

Rebase at **push** time, not before every commit — a fetch per commit is slow
and buys nothing while the work is still local. Resolve conflicts as they come
up rather than letting them pile up. Don't force-push a branch someone else may
be working on without saying so.

## Git hygiene

- **Commit only when asked.** Finishing a change is not a cue to commit it.
  Leave the work in the tree for review unless the user asks for a commit.
- **Don't push or open a PR/MR unless asked.** Remote operations are the user's
  call. (GitLab repos say *merge request*, not *pull request*.)
- **Commit only what was asked for.** Stage the files belonging to the change;
  don't `git add -A` and sweep in unrelated edits already in the tree.
- **Match the repository's existing message style.** Read `git log` first —
  subject casing, punctuation and whether prefixes are used vary per repo. Don't
  impose a convention the history doesn't already use.

## No agent attribution in git history

Commits, PR/MR titles, bodies and branch names must **credit no AI assistant**.
No `Co-Authored-By:` trailer naming one, no "Generated with ..." footer, no
robot byline, no assistant email address.

Write the message as the author would: what changed and why.

Naming a tool as the **subject** of the work is fine — a commit that configures
Claude Code will obviously say so. What's banned is crediting it as an
**author**. Where a tool can enforce this it does (Claude Code blocks it for
`-m`, `-F`, and PR/MR bodies), but a message typed into `$EDITOR` is invisible
to any such check, so the rule holds regardless.

## Change things with code, not by hand

Never make a one-off manual change to infrastructure or shared configuration —
no clicking through a cloud console, no editing live state, no imperative CLI
mutation that leaves nothing behind to review.

Every change lands as code that is committed and reviewable: Terraform or
equivalent IaC for infrastructure, GitOps manifests for cluster state, config
files in a repo for tooling. The repository must remain the source of truth, so
the change can be diffed, rolled back and reproduced on another machine.

If something genuinely cannot be expressed as code — a one-time account
bootstrap, a vendor portal with no API — treat it like a host install: stop,
hand the exact steps to the user with the reason, and let them decide. Do not
perform it silently.
