#!/usr/bin/env bash
# Apply a tmux theme by id from themes.tsv.
#   apply.sh <id>         apply + persist the choice
#   apply.sh --restore    re-apply the last-persisted choice (used at tmux startup)
# Clones the theme repo on demand the first time it is used.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV="$HERE/themes.tsv"
PLUGIN_DIR="$HOME/.tmux/plugins"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-theme"
STATE_FILE="$STATE_DIR/current"

log() { printf '%s\n' "$*" >&2; }

row_for() {
  # Print the tab-separated row whose id (field 1) matches $1.
  awk -F'\t' -v id="$1" '$1 == id {print; exit}' "$TSV"
}

apply_id() {
  local id="$1" persist="${2:-1}"
  local row group name repo dir kind target options palette
  row="$(row_for "$id")"
  if [ -z "$row" ]; then log "tmux-theme: unknown theme '$id'"; return 1; fi
  IFS=$'\t' read -r id group name repo dir kind target options palette <<<"$row"

  local repo_path="$PLUGIN_DIR/$dir"

  # Clone on demand.
  if [ ! -d "$repo_path" ] && [ "$repo" != "-" ]; then
    log "tmux-theme: installing $group $name ..."
    mkdir -p "$PLUGIN_DIR"
    if ! git clone --depth 1 "$repo" "$repo_path" >/dev/null 2>&1; then
      log "tmux-theme: failed to clone $repo"
      return 1
    fi
  fi

  # Nothing to apply to without a server (choice is still persisted below).
  if tmux info >/dev/null 2>&1; then
    # Set any plugin options first.
    if [ "$options" != "-" ]; then
      local IFS=';'
      local pair k v
      for pair in $options; do
        k="${pair%%=*}"; v="${pair#*=}"
        tmux set -g "$k" "$v"
      done
      unset IFS
    fi

    # Resolve the file to load.
    local file="$repo_path/$target"
    if [ "$target" = "-" ] || [ ! -f "$file" ]; then
      if [ "$kind" = "source" ]; then
        file="$(find "$repo_path" -maxdepth 2 -name '*.conf' 2>/dev/null | head -1)"
      else
        file="$(find "$repo_path" -maxdepth 1 -name '*.tmux' 2>/dev/null | head -1)"
      fi
    fi
    if [ -z "${file:-}" ] || [ ! -f "$file" ]; then
      log "tmux-theme: could not find theme file for $id in $repo_path"
      return 1
    fi

    if [ "$kind" = "source" ]; then
      tmux source-file "$file"
    else
      tmux run-shell "$file"
    fi
    tmux set -g @tmux_theme_current "$id" 2>/dev/null || true
  fi

  if [ "$persist" = "1" ]; then
    mkdir -p "$STATE_DIR"
    printf '%s\n' "$id" > "$STATE_FILE"
  fi
  log "tmux-theme: applied $group $name"
}

case "${1:-}" in
  --restore)
    [ -f "$STATE_FILE" ] || exit 0
    apply_id "$(cat "$STATE_FILE")" 0 || exit 0
    ;;
  "" )
    log "usage: apply.sh <id> | --restore"; exit 2
    ;;
  *)
    apply_id "$1" 1
    ;;
esac
