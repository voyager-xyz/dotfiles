#!/usr/bin/env bash
# Render a color-swatch preview for a colorscheme id (used by fzf --preview).
#   preview.sh <id>
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV="$HERE/themes.tsv"
id="${1:-}"

row="$(awk -F'\t' -v id="$id" '$1 == id {print; exit}' "$TSV")"
[ -z "$row" ] && { echo "No preview"; exit 0; }
IFS=$'\t' read -r id group name colorscheme palette <<<"$row"

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

# truecolor foreground text on the theme background
fgtext() { # $1=fg hex  $2=bg hex  $3=text
  local fh="${1#\#}" bh="${2#\#}" fr fg fb br bg bb
  fr=$((16#${fh:0:2})); fg=$((16#${fh:2:2})); fb=$((16#${fh:4:2}))
  br=$((16#${bh:0:2})); bg=$((16#${bh:2:2})); bb=$((16#${bh:4:2}))
  printf '\033[48;2;%d;%d;%dm\033[38;2;%d;%d;%dm%s\033[0m' "$br" "$bg" "$bb" "$fr" "$fg" "$fb" "$3"
}

bold=$'\033[1m'; dim=$'\033[2m'; rst=$'\033[0m'

printf '%s%s · %s%s\n' "$bold" "$group" "$name" "$rst"
printf '%scolorscheme:%s %s\n\n' "$dim" "$rst" "$colorscheme"

# palette: bg, purple, blue, green, orange, red, yellow, fg
IFS=',' read -ra cols <<<"$palette"
bg="${cols[0]}"; purple="${cols[1]}"; blue="${cols[2]}"; green="${cols[3]}"
orange="${cols[4]}"; red="${cols[5]}"; yellow="${cols[6]}"; fg="${cols[7]:-#ffffff}"

# Big swatch band
band=""
for c in "${cols[@]}"; do band+="$(block "$c" '   ')"; done
printf '%s\n%s\n%s\n\n' "$band" "$band" "$band"

# Per-color rows with hex labels
for c in "${cols[@]}"; do
  printf '%s  %s%s%s\n' "$(block "$c" '    ')" "$dim" "$c" "$rst"
done

# Mock editor lines using the palette, painted on the theme background.
printf '\n%spreview:%s\n' "$dim" "$rst"
pad="                              "
printf '%s\n' "$(block "$bg" " ")$(fgtext "$purple" "$bg" "local")$(fgtext "$fg" "$bg" " ")$(fgtext "$blue" "$bg" "greet")$(fgtext "$fg" "$bg" " = ")$(fgtext "$green" "$bg" "\"hello\"")$(block "$bg" "$pad")"
printf '%s\n' "$(block "$bg" " ")$(fgtext "$red" "$bg" "if")$(fgtext "$fg" "$bg" " x ")$(fgtext "$orange" "$bg" ">")$(fgtext "$yellow" "$bg" " 42")$(fgtext "$fg" "$bg" " then")$(block "$bg" "$pad")"
printf '%s\n' "$(block "$bg" " ")$(fgtext "$purple" "$bg" "  return")$(fgtext "$fg" "$bg" " greet")$(block "$bg" "$pad")"
printf '%s\n' "$(block "$bg" " ")$(fgtext "$red" "$bg" "end")$(block "$bg" "$pad")"
