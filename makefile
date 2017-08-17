
all: shellinit npminit viminit


shellinit:
	cd shell/bash && ./bash_init.sh

npminit:
	cd npm && ./npm_init.sh

viminit:
	cd vim && ./vim_init.sh

clean:
	cd ~ && rm -rf .bashrc .bash_aliases .npm .npm-packages .npmrc .vim .vimrc

