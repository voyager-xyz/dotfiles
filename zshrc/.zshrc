export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git rails vscode)
source $ZSH/oh-my-zsh.sh

alias gg="lazygit"

# ruby
alias be="bundle exec"
alias bi="bundle install"
alias t="bundle exec rspec"
alias r="./bin/rails"
alias rg="./bin/rails generate"

# python
alias pr="poetry run"
alias pt="poetry run pytest"
alias ptv="poetry run pytest -vv"

# other
alias ee="exit"
alias ev="cd ~/.config/nvim"
alias chns='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias n="nvim ."
alias y="yazi"
alias mux="tmuxinator"
alias tka="tmux kill-server"
alias dclaude="claude --dangerously-skip-permissions"
#############
eval "$(zoxide init zsh)"
source ~/.zshrc_func
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
export NVM_DIR="$HOME/.nvm"

[ -f "${HOME}/.cultureamp" ] && source "${HOME}/.cultureamp"
# tmuxinator start "notes"
