#!/bin/zsh
BASE_DIR="/Users/jarrod.folino/Code/dotfiles"
stow -d $BASE_DIR -R -t ~ zshrc --adopt
stow -d $BASE_DIR -R -t ~ starship --adopt
stow -d $BASE_DIR -R -t ~ ghostty --adopt
stow -d $BASE_DIR -R -t ~ atuin --adopt
stow -d $BASE_DIR -R -t ~ zoxide --adopt
stow -d $BASE_DIR -R -t ~ yazi --adopt

. ~/.zshrc
. ~/.zshrc_func
exec zsh -l
