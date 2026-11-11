#!/usr/bin/env bash
# viu-watch.sh [DIR]
# Show the newest .png in DIR with viu, and redraw when a newer one appears or the window is resized.
# Run it inside a kitty window for full-resolution images.
dir="${1:-.}"
viu="${VIU:-$(command -v viu || echo "$HOME/.cargo/bin/viu")}"
[ -x "$viu" ] || { echo "viu not found; install it (cargo install viu) or set VIU=/path/to/viu" >&2; exit 1; }

mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null; }  # GNU, then BSD/macOS

last=""
while true; do
  f=$(ls -t "$dir"/*.png 2>/dev/null | head -1)
  key="$f $(mtime "$f") $(tput cols)x$(tput lines)"
  if [ -n "$f" ] && [ "$key" != "$last" ]; then
    clear
    printf '\033_Ga=d\033\\'          # drop the previous kitty image; other terminals ignore this
    printf '%s  (%s)\n' "$(basename "$f")" "$(date '+%H:%M:%S')"
    "$viu" "$f"                       # no -w: viu fits the window itself, and forcing a width looked worse in kitty
    last="$key"
  elif [ -z "$f" ] && [ "$last" != "none" ]; then
    clear
    echo "Waiting for a .png in $dir"
    last="none"
  fi
  sleep 1
done
