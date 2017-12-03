
all: shellinit npminit viminit tmuxinit


shellinit:
	cd shell/bash && ./bash_init.sh

npminit:
	cd npm && ./npm_init.sh

viminit:
	cd vim && ./vim_init.sh

tmuxinit:
	cd tmux && ./tmux_init.sh

clean:
	cd ~ && rm -rf .bashrc .bash_aliases .npm .npm-packages .npmrc .vim .vimrc .tmux.conf

