export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git rails vscode)
source $ZSH/oh-my-zsh.sh

alias gg="lazygit"
alias be="bundle exec"
alias bi="bundle install"
alias t="bundle exec rspec"
alias r="./bin/rails"
alias rg="./bin/rails generate"
alias pr="poetry run"
alias pt="poetry run pytest"
alias ptv="poetry run pytest -vv"
alias ee="exit"
alias chns='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias g="git status"
alias n="nvim ."

eval "$(pyenv init -)"
source ~/.zshrc_func
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional

zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
# ruby
export RUBYOPT="-r$HOME/.rubyopenssl_default_store.rb $RUBYOPT"

# javascript
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# enhance shell
ji
