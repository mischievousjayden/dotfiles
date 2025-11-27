# Setup Vim Config

## Setup the config
```
bash vim_init.sh
```

## Add plugin
```
git submodule add <git url> pack/<package group name>/{start,opt}/<package name>
```
example:
```
git submodule add https://github.com/tomtom/tcomment_vim.git pack/utils/start/tcomment_vim
```

## Clone submodules
```
git submodule update --init --recursive
```

## Remove submodules
### Check submodule
```
git submodule
```

### Deinitialize submodule
```
git submodule deinit -f <submodule path>
```
example:
```
git submodule deinit -f pack/utils/start/tcomment_vim
```

### Remove the submodule directory
```
rm -rf <submodule path>
```
example:
```
rm -rf pack/utils/start/tcomment_vim
```

### Remove from `.gitmodules`
```
git config -f .gitmodules --remove-section submodule.<submodule path>
```
example:
```
git config -f .gitmodules --remove-section submodule.vim/pack/utils/start/tcomment_vim
```

## reference
- basic vim configuration: https://computers.tutsplus.com/tutorials/basic-vim-configuration--cms-21498
- how to vimrc: https://dougblack.io/words/a-good-vimrc.html
- top 50 vim configuration options: https://www.shortcutfoo.com/blog/top-50-vim-configuration-options/
- show invisibles: http://vimcasts.org/episodes/show-invisibles/
- pathogen git submodule: http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/
- example vimrc: https://github.com/daniiln/dotfiles/tree/master/vim
