
all: vim, npm


vim:
	cd vimsetting && ./vim_init.sh

npm:
	cd npm && ./npm_init.sh

