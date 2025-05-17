export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'
export ARTIFACTORY_PASSWORD="cmVmdGtuOjAxOjE3NzYxNTcxMjE6NzEycW5BTzFjaDI0V1RXRHNJZ3d5blFtWk5X"
export ARTIFACTORY_USER="jarrod.folino@fundingcircle.com"

# alias refresh="python /Users/jarrod.folino/Code/cuiwork/scripts/src/get_lambdas.py > /Users/jarrod.folino/Code/public/data.json"
alias lg="lazygit"
alias m="make"
alias esb="cd /Users/jarrod.folino/Code/_sandbox"
alias ee="exit"
alias chns='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias jf="/Users/jarrod.folino/.jf/main.sh"
alias g="git status"
alias c="code ."
alias n="nvim ."

eval "$(pyenv init -)"
source ~/.zshrc_func
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/jarrod.folino/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
