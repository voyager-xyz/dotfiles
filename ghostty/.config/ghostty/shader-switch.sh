#!/usr/bin/env bash
# Interactive Ghostty custom-shader switcher (fzf + live preview).
# Bound to the `,s` shell alias. Mirrors the tmux (`,u`) / nvim (`,un`) switchers.
#
# As you move through the list each shader is written into the Ghostty config
# and applied live by triggering Ghostty's reload-config keybind, so you see the
# effect in real time. Enter keeps the highlighted shader; Esc restores the one
# that was active when you opened the picker.
#
# Subcommand (used internally by fzf, but also usable directly):
#   shader-switch.sh apply <name|none>   write <name> into config and reload
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HERE/config"
SHADER_DIR="$HERE/shaders"
SELF="${BASH_SOURCE[0]}"

# Read the basename of the currently configured shader, or "none".
current_shader() {
  local line
  line="$(grep -E '^[[:space:]]*custom-shader[[:space:]]*=' "$CONFIG" | tail -1 || true)"
  if [ -z "$line" ]; then printf 'none\n'; return; fi
  basename "${line#*=}" | tr -d ' '
}

# Ask Ghostty to reload its config (default keybind super+shift+,).
reload_ghostty() {
  osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}' \
    >/dev/null 2>&1 || true
}

# Rewrite the custom-shader line in-place (preserving the stow symlink) and reload.
#   apply_shader <name|none>
apply_shader() {
  local name="$1" tmp
  tmp="$(mktemp)"
  grep -vE '^[[:space:]]*custom-shader[[:space:]]*=' "$CONFIG" > "$tmp" || true
  if [ "$name" != "none" ]; then
    printf 'custom-shader = %s\n' "$SHADER_DIR/$name" >> "$tmp"
  fi
  cat "$tmp" > "$CONFIG"   # write through the symlink, don't replace it
  rm -f "$tmp"
  reload_ghostty
}

# Internal entry point used by the fzf focus binding.
if [ "${1:-}" = "apply" ]; then
  apply_shader "${2:-none}"
  exit 0
fi

command -v fzf >/dev/null 2>&1 || { echo "fzf not found in PATH" >&2; exit 1; }

original="$(current_shader)"
current="$original"

list() {
  printf 'none\n'
  find "$SHADER_DIR" -maxdepth 1 -name '*.glsl' -exec basename {} \; | sort
}

# Mark the active shader with a dot in the visible label.
labelled() {
  local name
  while IFS= read -r name; do
    if [ "$name" = "$current" ]; then
      printf '%s\t● %s\n' "$name" "$name"
    else
      printf '%s\t  %s\n' "$name" "$name"
    fi
  done
}

preview='if [ {1} = none ]; then echo "(no custom shader — plain terminal)"; '
preview+="else bat --color=always --style=plain --language=glsl '$SHADER_DIR/'{1} 2>/dev/null || cat '$SHADER_DIR/'{1}; fi"

sel="$(
  list | labelled | fzf \
    --ansi \
    --delimiter='\t' \
    --with-nth=2 \
    --nth=2 \
    --prompt='ghostty shader ❯ ' \
    --header=$'enter: keep   esc: restore   (live preview as you move)\n' \
    --height=100% \
    --layout=reverse \
    --border=rounded \
    --bind="focus:execute-silent($SELF apply {1})" \
    --preview="$preview" \
    --preview-window='right,52%,border-left,wrap'
)" || {
    # Cancelled — put the original shader back.
    apply_shader "$original"
    exit 0
  }

id="${sel%%$'\t'*}"
[ -z "$id" ] && { apply_shader "$original"; exit 0; }

# Selection is already applied live; this just guarantees the final state.
apply_shader "$id"
