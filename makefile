
all: shellinit npminit viminit tmuxinit aiagentsinit


shellinit:
	cd shell/bash && ./bash_init.sh

npminit:
	cd npm && ./npm_init.sh

viminit:
	cd vim && ./vim_init.sh

tmuxinit:
	cd tmux && ./tmux_init.sh

aiagentsinit:
	cd ai-agents && ./ai_agents_init.sh

clean: aiagentsclean
	cd ~ && rm -rf .bashrc .bash_aliases .npm .npm-packages .npmrc .vim .vimrc .tmux.conf

# Removes only what ai_agents_init.sh installed: symlinks pointing back into
# this repo, plus the copied settings.json. Leaves the rest of ~/.claude alone
# (sessions, history, credentials).
aiagentsclean:
	find ~/.claude -maxdepth 2 -type l -lname "$(PWD)/ai-agents/*" -delete
	rm -f ~/.claude/settings.json
	-rmdir ~/.claude/shared 2>/dev/null

