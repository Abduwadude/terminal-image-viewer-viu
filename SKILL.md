---
name: terminal-image-viewer-viu
description: Show screenshots and other local images to the user in a terminal window using viu, at full resolution in kitty. Use when the user asks to see, preview, inspect or compare an image or screenshot "in the terminal", after taking a UI or Playwright screenshot during UI work or visual QA, or when they mention viu. Opens a live preview window that refreshes on each new screenshot, or a grid to compare several.
---

# Terminal Image Viewer (viu)

## The one thing to know

Your shell tool has no TTY. Anything you run there, including `viu`, is captured and returned to you; it never appears on the user's screen. A zero exit code from `viu` proves nothing about what the user saw.

So you do not draw images in your own shell. You open a **separate terminal window** on the user's desktop that draws them. Use **kitty**: viu uses kitty's graphics protocol there and shows the real image. In most other terminals (for example GNOME Terminal on VTE without sixel) viu falls back to coloured half-block characters, which are too coarse for reviewing a UI.

Never:
- redirect `viu` output to `/dev/null` or treat its exit code as "displayed";
- write into the TTY of the agent's own terminal (it corrupts the agent's screen);
- claim the user saw an image. Say "it's in the preview window" and let them confirm;
- `pgrep -f`/`pkill -f` the script name: your own shell's command line contains it, so pgrep matches itself and pkill kills your shell. Use the `ps | awk` check below and `kill <pid>`.

## Requirements

- `viu` (`cargo install viu`, or a release binary from https://github.com/atanunq/viu/releases)
- `kitty` (any recent version) and a graphical session (`$DISPLAY` or `$WAYLAND_DISPLAY` set)
- The scripts in `scripts/` of this skill (bash; GNU or BSD userland)

Below, `SKILL_DIR` is the folder this file is in (usually `~/.claude/skills/terminal-image-viewer-viu`).

## One image, kept live: the preview window

Use this for normal UI work. Open the window once; after that every new `.png` saved to the watched folder appears in it within about a second, so you never need to run viu again.

1. Save screenshots into one folder in the project, for example `.playwright-mcp/` for the Playwright MCP server.
2. Check whether the preview window is already running:
   ```bash
   ps -eo pid,args | awk '$2=="bash" && $3 ~ /viu-watch\.sh$/'
   ```
3. If nothing is printed, open it:
   ```bash
   kitty --title "Screenshot preview" --detach "$SKILL_DIR/scripts/viu-watch.sh" "$PWD/.playwright-mcp"
   ```
4. Take the screenshot. The window shows the newest `.png` with its filename and the time it was drawn. It also redraws when the window is resized.
5. Tell the user it is in the preview window and ask them to confirm the first time.

## Several images side by side: the grid

Use this to compare before/after, desktop/phone or light/dark. It opens one kitty window split into a grid, one full-resolution pane per image. It is a snapshot and does not refresh.

```bash
"$SKILL_DIR/scripts/viu-grid.sh" before.png after.png             # specific files
"$SKILL_DIR/scripts/viu-grid.sh" -n 3 "$PWD/.playwright-mcp"     # the 3 newest
```

Prefer kitty's own splits over tmux. tmux before 3.3 cannot pass kitty graphics through, so viu inside tmux falls back to half-blocks. With tmux 3.3+ you can set `set -g allow-passthrough on`, but kitty splits need no configuration.

## Fallbacks

- **No kitty:** open the same script in the terminal the user has (for example `gnome-terminal -- "$SKILL_DIR/scripts/viu-watch.sh" "$PWD/.playwright-mcp"`). Tell the user the image will be blocky. On some Ubuntu setups the `/usr/bin/gnome-terminal` Python wrapper crashes with a `gi` import error when launched from an agent's shell; `/usr/bin/gnome-terminal.real` works.
- **No graphical session** (SSH, headless): you cannot open a window. Give the user the exact command to run in their own terminal, for example `viu "/abs/path/screenshot.png"`. With Claude Code they can type it with a `!` prefix to run it in the session.
- **The agent already runs inside tmux** (`$TMUX_PANE` is set): you can open the watcher in a side pane with `tmux split-window -h -d -l 45% -t "$TMUX_PANE" "$SKILL_DIR/scripts/viu-watch.sh '$PWD/.playwright-mcp'"`. Image quality follows the outer terminal and tmux passthrough rules above.

## Closing

The user closes the windows. If you must close the preview yourself, find its pid with the `ps | awk` check and `kill <pid>`.
