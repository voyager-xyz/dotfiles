#!/usr/bin/env bash
# Render a color-swatch preview for a theme id (used by fzf --preview).
#   preview.sh <id>
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV="$HERE/themes.tsv"
id="${1:-}"

row="$(awk -F'\t' -v id="$id" '$1 == id {print; exit}' "$TSV")"
[ -z "$row" ] && { echo "No preview"; exit 0; }
IFS=$'\t' read -r id group name repo dir kind target options palette <<<"$row"

# truecolor block for a hex color
block() { # $1=hex  $2=text
  local hex="${1#\#}" r g b
  if [ "$hex" = "default" ] || [ ${#hex} -lt 6 ]; then
    printf '\033[0m%s' "${2:-      }"; return
  fi
  r=$((16#${hex:0:2})); g=$((16#${hex:2:2})); b=$((16#${hex:4:2}))
  # pick black/white fg for contrast
  local lum=$(( (r*299 + g*587 + b*114) / 1000 )) fg
  if [ "$lum" -gt 140 ]; then fg='38;2;0;0;0'; else fg='38;2;255;255;255'; fi
  printf '\033[48;2;%d;%d;%dm\033[%sm%s\033[0m' "$r" "$g" "$b" "$fg" "${2:-      }"
}

bold=$'\033[1m'; dim=$'\033[2m'; rst=$'\033[0m'

printf '%s%s · %s%s\n' "$bold" "$group" "$name" "$rst"
printf '%s%s%s\n\n' "$dim" "$repo" "$rst"

# Big swatch band
band=""
IFS=',' read -ra cols <<<"$palette"
for c in "${cols[@]}"; do band+="$(block "$c" '   ')"; done
printf '%s\n%s\n%s\n\n' "$band" "$band" "$band"

# Per-color rows with hex labels
for c in "${cols[@]}"; do
  printf '%s  %s%s%s\n' "$(block "$c" '    ')" "$dim" "$c" "$rst"
done

printf '\n%skind:%s %s   %ssource:%s %s\n' "$dim" "$rst" "$kind" "$dim" "$rst" "$dir"
[ "$options" != "-" ] && printf '%soptions:%s %s\n' "$dim" "$rst" "$options"

# Mock status bar using the palette's first few colors (bg, accent, fg)
bg="${cols[0]}"; accent="${cols[1]:-$bg}"; fg="${cols[7]:-${cols[4]:-#ffffff}}"
printf '\n%spreview status bar:%s\n' "$dim" "$rst"
printf '%s%s%s%s\n' \
  "$(block "$accent" " 1 ")" \
  "$(block "$bg" " 2:zsh  3:nvim  4:logs ")" \
  "$(block "$accent" " ")" \
  "$(block "$bg" "")"
