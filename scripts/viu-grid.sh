#!/usr/bin/env bash
# viu-grid.sh FILE.png...      show these images
# viu-grid.sh -n N DIR         show the N newest .png files in DIR
# Opens one kitty window split into a grid, one full-resolution viu pane per image.
set -euo pipefail
viu="${VIU:-$(command -v viu || echo "$HOME/.cargo/bin/viu")}"
[ -x "$viu" ] || { echo "viu not found; install it (cargo install viu) or set VIU=/path/to/viu" >&2; exit 1; }
command -v kitty >/dev/null || { echo "kitty not found; the grid needs kitty" >&2; exit 1; }

if [ "${1:-}" = "-n" ]; then
  [ $# -eq 3 ] || { echo "usage: viu-grid.sh -n N DIR" >&2; exit 2; }
  files=()
  # while-read instead of mapfile: macOS ships bash 3.2, which has no mapfile
  while IFS= read -r f; do files+=("$f"); done < <(ls -t "$3"/*.png 2>/dev/null | head -"$2")
else
  files=("$@")
fi
[ "${#files[@]}" -gt 0 ] || { echo "no images to show" >&2; exit 1; }

session=$(mktemp "${TMPDIR:-/tmp}/viu-grid.XXXXXX")
{
  echo "layout grid"
  for f in "${files[@]}"; do
    f=$(cd "$(dirname "$f")" && pwd)/$(basename "$f")
    printf 'launch --title %q sh -c %q\n' "$(basename "$f")" \
      "printf '%s\n' \"$(basename "$f")\"; \"$viu\" \"$f\"; exec sleep 2147483647"
  done
} > "$session"
kitty --title "Screenshots (${#files[@]})" --session "$session" --detach
