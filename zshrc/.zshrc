export LC_CTYPE=en_US.UTF-8
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8

export PATH="$HOME/Code/dotfiles/scripts:$PATH"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
# fzf-tab must come before plugins that wrap widgets (autosuggestions); and
# zsh-syntax-highlighting must be LAST in this list (it wraps the line editor).
plugins=(git rails vscode fzf-tab zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
source /Users/jarrod.folino/Code/ruby_ast_analyser/completions/make-tasks.zsh

autoload -Uz compinit
compinit

alias gg="lazygit"
alias m="make"

# eza (modern ls)
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias la="eza -a --icons --group-directories-first"
alias lt="eza --tree --level=2 --icons --group-directories-first"

# claude
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_TRACES_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=http://127.0.0.1:5080/api/default
export OTEL_EXPORTER_OTLP_HEADERS=Authorization=Basic cm9vdEBleGFtcGxlLmNvbTpDb21wbGV4cGFzcyMxMjM=
alias ,c="claude --dangerously-skip-permissions"

# tmux theme switcher (fzf). Type ,u at any prompt — works in or out of tmux.
alias ,u="$HOME/.config/tmux-theme/switch.sh"

# nvim colorscheme switcher (fzf). Type ,un at any prompt — applies to running
# nvim instances and persists for new ones (nvim-astro reads the choice).
alias ,un="$HOME/.config/nvim-theme/switch.sh"

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
# fzf: use fd (fast, respects .gitignore, includes hidden files) as the default
# source for bare `fzf` and Ctrl-T.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
