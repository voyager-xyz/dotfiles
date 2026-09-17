export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PATH="$HOME/Code/dotfiles/scripts:$PATH"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Skip omz's periodic background `git fetch` of itself.
DISABLE_AUTO_UPDATE=true
# Skip compaudit's insecure-directory scan on every compinit (~15ms, and it
# re-stats every fpath entry).
DISABLE_COMPFIX=true
# Don't install url-quote-magic / bracketed-paste-magic. They wrap the paste
# widget and run zsh code per pasted character, which is what makes pasting a
# long command into omz feel sluggish.
DISABLE_MAGIC_FUNCTIONS=true

# Trimmed from (git rails vscode fzf-tab zsh-autosuggestions
# zsh-syntax-highlighting). Measured against 10k lines of ~/.zsh_history:
#   rails   -- 60 aliases, 0 used
#   vscode  -- 14 aliases, 0 used
#   git     -- ~150 aliases, 3 used (gst 38x, gco 4x, gprom 1x), re-aliased
#              by hand below. It was also the source of ~500 of the ~835
#              compdef calls at startup.
# fzf-tab must come before plugins that wrap widgets (autosuggestions); and
# zsh-syntax-highlighting must be LAST in this list (it wraps the line editor).
plugins=(fzf-tab zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# The only three survivors of the omz git plugin.
alias gst="git status"
alias gco="git checkout"
alias gprom="git pull --rebase origin main"
[ -f /Users/jarrod.folino/Code/ruby_ast_analyser/completions/make-tasks.zsh ] && source /Users/jarrod.folino/Code/ruby_ast_analyser/completions/make-tasks.zsh

alias lazygit='env -u DEVELOPER_DIR lazygit'
alias ,lg="lazygit"

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
alias ,c="claude"

alias ,u="$HOME/.config/tmux-theme/switch.sh"
alias ,un="$HOME/.config/nvim-theme/switch.sh"
alias ,s="$HOME/.config/ghostty/shader-switch.sh"
alias be="bundle exec"
alias bi="bundle install"
alias r="./bin/rails"
alias pr="poetry run"
alias pt="poetry run pytest"
alias ee="exit"
alias chns='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias n="NVIM_APPNAME=nvim-astro nvim"
alias nastro="NVIM_APPNAME=nvim-astro nvim"
alias nchad="NVIM_APPNAME=nvim-chad nvim"
alias nlazy="NVIM_APPNAME=nvim-lazy nvim"

alias tko="tmux kill-server"
#############
source ~/.zshrc_func
# fzf: use fd (fast, respects .gitignore, includes hidden files) as the default
# source for bare `fzf` and Ctrl-T.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export CARAPACE_BRIDGES='zsh,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
# Cache carapace's ~20KB init instead of regenerating it on every startup.
# Rebuilt whenever the carapace binary is newer than the cache.
_carapace_cache="${XDG_CACHE_HOME:-$HOME/.cache}/carapace-init.zsh"
if [[ ! -s $_carapace_cache || $commands[carapace] -nt $_carapace_cache ]]; then
  mkdir -p ${_carapace_cache:h}
  carapace _carapace zsh >| $_carapace_cache
fi
source $_carapace_cache
unset _carapace_cache

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


# node version manager. Replaced nvm, whose nvm.sh cost 819ms per interactive
# shell -- 56% of total startup -- because nvm_auto re-validated the install on
# every launch. fnm does the same job in ~10ms.
#
# Deliberately no --use-on-cd: every ~/Code repo carrying a .nvmrc also has
# devbox.json + .envrc, and devbox/direnv puts its own node on PATH, winning
# over whatever the version manager selected. So the hook only cost a chpwd
# subprocess and printed "Requested version vX is not currently installed" on
# each cd. Run `fnm use` by hand for the rare non-devbox project.
if (( $+commands[fnm] )); then
  eval "$(fnm env --shell zsh)"
fi
