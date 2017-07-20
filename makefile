
all: npminit viminit


npminit:
	cd npm && ./npm_init.sh

viminit:
	cd vimsetting && ./vim_init.sh

