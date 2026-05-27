#!/bin/zsh
BASE_DIR="${HOME}/Code/dotfiles"
stow -d $BASE_DIR -R -t ~ zshrc --adopt
stow -d $BASE_DIR -R -t ~ starship --adopt
stow -d $BASE_DIR -R -t ~ ghostty --adopt
stow -d $BASE_DIR -R -t ~ yazi --adopt
stow -d $BASE_DIR -R -t ~ tmuxinator
stow -d $BASE_DIR -R -t ~ tmux
stow -d $BASE_DIR -R -t ~ git --adopt

. ~/.zshrc
. ~/.zshrc_func
exec zsh -l
