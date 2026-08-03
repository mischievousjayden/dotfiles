.DEFAULT_GOAL := all

.PHONY: all help \
        shellinit bashinit zshinit viminit tmuxinit aiagentsinit \
        clean shellclean bashclean zshclean vimclean tmuxclean aiagentsclean

all: shellinit viminit tmuxinit aiagentsinit

help:
	@echo "install:"
	@echo "  make               everything (same as 'make all')"
	@echo "  make shellinit     bash + zsh"
	@echo "  make bashinit      bash only"
	@echo "  make zshinit       zsh only"
	@echo "  make viminit       vim + nvim (pulls plugin submodules)"
	@echo "  make tmuxinit      tmux"
	@echo "  make aiagentsinit  AI agent config"
	@echo ""
	@echo "uninstall — removes only symlinks pointing into this repo:"
	@echo "  make clean         everything"
	@echo "  make <tool>clean   e.g. zshclean, vimclean, aiagentsclean"
	@echo ""
	@echo "Re-running an install target is safe: links this repo created are"
	@echo "refreshed in place, anything else in the way is kept as <name>.backup."

# --- install ----------------------------------------------------------------
# The scripts locate the repo from their own path, so they run from anywhere.

shellinit: bashinit zshinit

bashinit:
	./shell/bash/bash_init.sh

zshinit:
	./shell/zsh/zsh_init.sh

viminit:
	./vim/vim_init.sh

tmuxinit:
	./tmux/tmux_init.sh

aiagentsinit:
	./ai-agents/ai_agents_init.sh

# --- uninstall --------------------------------------------------------------
# Each script removes what it installed — the makefile deliberately keeps no
# list of its own, which is what let the old `clean` drift out of sync.

clean: shellclean vimclean tmuxclean aiagentsclean

shellclean: bashclean zshclean

bashclean:
	./shell/bash/bash_init.sh --uninstall

zshclean:
	./shell/zsh/zsh_init.sh --uninstall

vimclean:
	./vim/vim_init.sh --uninstall

tmuxclean:
	./tmux/tmux_init.sh --uninstall

aiagentsclean:
	./ai-agents/ai_agents_init.sh --uninstall
