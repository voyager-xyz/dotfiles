#!/usr/bin/env bash
# Apply a Neovim colorscheme by id from themes.tsv.
#   apply.sh <id>     persist the choice + live-apply to running nvim instances
#   apply.sh --print  print the persisted colorscheme name (used by astroui.lua)
# New nvim instances pick up the persisted choice via lua/plugins/astroui.lua.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV="$HERE/themes.tsv"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim-theme"
STATE_FILE="$STATE_DIR/current"

log() { printf '%s\n' "$*" >&2; }

colorscheme_for() {
  # Print the colorscheme (field 4) for the row whose id (field 1) matches $1.
  awk -F'\t' -v id="$1" '$1 == id {print $4; exit}' "$TSV"
}

label_for() {
  awk -F'\t' -v id="$1" '$1 == id {printf "%s %s", $2, $3; exit}' "$TSV"
}

# Send `:colorscheme <cs>` to every running nvim instance. lazy.nvim
# auto-loads the owning plugin when the colorscheme is requested.
live_apply() {
  local cs="$1" run_dir sock count=0
  run_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
  command -v nvim >/dev/null 2>&1 || return 0
  while IFS= read -r sock; do
    [ -S "$sock" ] || continue
    if nvim --server "$sock" --remote-expr "execute('colorscheme $cs')" >/dev/null 2>&1; then
      count=$((count + 1))
    fi
  done < <(find "$run_dir" -maxdepth 4 -type s -name 'nvim.*' 2>/dev/null)
  [ "$count" -gt 0 ] && log "nvim-theme: applied to $count running instance(s)"
  return 0
}

case "${1:-}" in
  --print)
    [ -f "$STATE_FILE" ] && cat "$STATE_FILE"
    exit 0
    ;;
  "")
    log "usage: apply.sh <id> | --print"; exit 2
    ;;
esac

id="$1"
cs="$(colorscheme_for "$id")"
if [ -z "$cs" ]; then log "nvim-theme: unknown theme '$id'"; exit 1; fi

mkdir -p "$STATE_DIR"
printf '%s\n' "$cs" > "$STATE_FILE"

live_apply "$cs"
log "nvim-theme: set $(label_for "$id")  ($cs)"
