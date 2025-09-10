export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'
export ARTIFACTORY_PASSWORD="cmVmdGtuOjAxOjE3NzYxNTcxMjE6NzEycW5BTzFjaDI0V1RXRHNJZ3d5blFtWk5X"
export ARTIFACTORY_USER="jarrod.folino@fundingcircle.com"

alias lg="lazygit"
alias m="make"
alias ee="exit"
alias chns='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias j="/Users/jarrod.folino/.j/main.sh"
alias g="git status"
alias c="code ."
alias n="nvim ."

eval "$(pyenv init -)"
source ~/.zshrc_func
source ~/.zoxide
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/jarrod.folino/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
