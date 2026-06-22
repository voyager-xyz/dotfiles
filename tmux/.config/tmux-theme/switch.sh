#!/usr/bin/env bash
# Interactive tmux theme switcher (fzf + color-swatch preview).
# Bound to the `,u` shell alias. Works inside or outside tmux.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV="$HERE/themes.tsv"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-theme/current"

command -v fzf >/dev/null 2>&1 || { echo "fzf not found in PATH" >&2; exit 1; }

current=""
[ -f "$STATE_FILE" ] && current="$(cat "$STATE_FILE")"

# fzf list: hidden id (field 1) + visible "Group · Name" label.
# Mark the currently-active theme with a dot.
list() {
  awk -F'\t' -v cur="$current" '
    {
      mark = ($1 == cur) ? "●" : " "
      printf "%s\t%s %-12s %s\n", $1, mark, $2, $3
    }' "$TSV"
}

sel="$(
  list | fzf \
    --ansi \
    --delimiter='\t' \
    --with-nth=2 \
    --nth=2 \
    --prompt='tmux theme ❯ ' \
    --header=$'enter: apply   esc: cancel\n' \
    --height=100% \
    --layout=reverse \
    --border=rounded \
    --preview="$HERE/preview.sh {1}" \
    --preview-window='right,52%,border-left,wrap'
)" || exit 0

id="${sel%%$'\t'*}"
[ -z "$id" ] && exit 0

exec "$HERE/apply.sh" "$id"
