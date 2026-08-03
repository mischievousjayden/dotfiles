# dotfiles

Shell, vim, tmux and AI agent config, installed by symlinking this repo into
`$HOME`.

```sh
git clone --recurse-submodules git@github.com:mischievousjayden/dotfiles.git
cd dotfiles && make
```

`make help` lists every target.

## Install

| Target | Installs |
| --- | --- |
| `make` / `make all` | everything below |
| `make shellinit` | bash + zsh (`bashinit` / `zshinit` for one) |
| `make viminit` | vim + nvim, and pulls the plugin submodules |
| `make tmuxinit` | tmux |
| `make aiagentsinit` | AI agent config — see [ai-agents/README.md](ai-agents/README.md) |

**Re-running is safe and reports `unchanged`.** A link this repo created is
refreshed in place; anything else in the way — a real file, or a link somewhere
else — is preserved as `<name>.backup` first, never overwritten.

## Uninstall

| Target | Removes |
| --- | --- |
| `make clean` | everything |
| `make <tool>clean` | one tool, e.g. `zshclean`, `vimclean`, `aiagentsclean` |

Uninstalling removes **only symlinks pointing into this repo**. Files you put
there yourself, and links belonging to anything else, are left alone.

## Layout

```
lib/dotfiles.sh   shared install/uninstall helpers, sourced by every script
shell/
  bash/ zsh/      per-shell rc + init script
  common/         functions and aliases shared by both shells
vim/ tmux/        config + init script
ai-agents/        AI agent config (its own README)
docs/             notes, e.g. per-project git identity
```

Each tool directory owns a `*_init.sh` that both installs and uninstalls it
(`--uninstall`). The makefile only delegates — it deliberately keeps no list of
installed files, since that duplication is what let `clean` drift out of sync
with reality.

The scripts locate the repo from their own path, so they work from any
directory:

```sh
./vim/vim_init.sh              # same as: cd vim && ./vim_init.sh
```

## Machine-local overrides

- `~/.custom_zshrc/` — every file in it is sourced by `zshrc`, in name order
- `~/.dotfiles_local/ai-agents/*.md` — extra agent context, never committed
- Per-project git identity — see [docs/local_git_configuration.md](docs/local_git_configuration.md)
