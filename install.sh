#!/bin/zsh
BASE_DIR="~/Code/dotfiles"
stow -d $BASE_DIR -R -t ~ zshrc
stow -d $BASE_DIR -R -t ~ nvim 
stow -d $BASE_DIR -R -t ~ starship
stow -d $BASE_DIR -R -t ~ ghostty
stow -d $BASE_DIR -R -t ~ atuin
stow -d $BASE_DIR -R -t ~ j
stow -d $BASE_DIR -R -t ~ zoxide

. ~/.zshrc
. ~/.zshrc_func
exec zsh -l
