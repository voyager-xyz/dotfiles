export LC_CTYPE=en_US.UTF-8
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8

export PATH="$HOME/Code/dotfiles/scripts:$PATH"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git rails vscode)

source $ZSH/oh-my-zsh.sh
source /Users/jarrod.folino/Code/ruby_ast_analyser/completions/make-tasks.zsh

autoload -Uz compinit
compinit

alias gg="lazygit"
alias m="make"

# claude
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_TRACES_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:5080/api/default
export OTEL_EXPORTER_OTLP_HEADERS=Authorization=Basic cm9vdEBleGFtcGxlLmNvbTpDb21wbGV4cGFzcyMxMjM=

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

alias tko="tmux kill-server"
alias j="jupyter"
alias h="hotel"
#############
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

[ -f "${HOME}/.cultureamp" ] && source "${HOME}/.cultureamp"


# The next line was added by hotel, leave it at the bottom of this file
source /Users/jarrod.folino/.config/hotel/config.zsh
