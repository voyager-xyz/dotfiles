export LC_CTYPE=en_US.UTF-8
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git rails vscode)
source $ZSH/oh-my-zsh.sh

alias gg="lazygit"
alias m="make"

# ruby
alias be="bundle exec"
alias bi="bundle install"
alias r="./bin/rails"

# python
alias pr="poetry run"
alias pt="poetry run pytest"

# other
alias ee="exit"
alias chns='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias n="NVIM_APPNAME=nvim-astro nvim"
alias nastro="NVIM_APPNAME=nvim-astro nvim"
alias nchad="NVIM_APPNAME=nvim-chad nvim"
alias nlazy="NVIM_APPNAME=nvim-lazy nvim"

alias tka="tmux kill-server"
alias dclaude="claude --dangerously-skip-permissions"
#############
# eval "$(zoxide init zsh)"
source ~/.zshrc_func
export CARAPACE_BRIDGES='zsh,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
export NVM_DIR="$HOME/.nvm"

report_tmux_status() {
  local exit_code=$?
  if [[ -n "$TMUX" ]]; then
    if [[ $exit_code -eq 0 ]]; then
      tmux set-option -g @tracked_status "#[fg=green,bold]✓"
    else
      tmux set-option -g @tracked_status "#[fg=red,bold]✗"
    fi
  fi
}
# Hook it into Zsh's precmd function
precmd_functions+=(report_tmux_status) 

[ -f "${HOME}/.cultureamp" ] && source "${HOME}/.cultureamp"

