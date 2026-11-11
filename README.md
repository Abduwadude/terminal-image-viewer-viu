# terminal-image-viewer-viu

[![shellcheck](https://github.com/Abduwadude/terminal-image-viewer-viu/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/Abduwadude/terminal-image-viewer-viu/actions/workflows/shellcheck.yml)

A Claude Code skill that lets the agent show you screenshots in a terminal window, at full resolution, while you keep working.

## The problem it solves

When a coding agent runs `viu screenshot.png`, nothing shows up for you. The agent's shell tool has no TTY, so the image is captured into the agent's own output. Telling you to run the command yourself every time gets old fast.

This skill has the agent open a separate **kitty** window instead:

- **Preview window:** shows the newest screenshot in a folder and redraws within a second whenever a new one lands. Open it once per session, and every Playwright screenshot after that appears by itself.
- **Grid:** puts several screenshots side by side in one kitty window, one pane each, for before/after or desktop/phone comparisons.

kitty matters. viu uses kitty's graphics protocol and shows the actual image. In terminals without image support it falls back to coloured half-blocks, which are too coarse to review a UI.

## Requirements

- [viu](https://github.com/atanunq/viu): `cargo install viu`
- [kitty](https://sw.kovidgoyal.net/kitty/)
- A desktop session (Linux X11/Wayland or macOS)
- bash

## Install

```bash
git clone https://github.com/Abduwadude/terminal-image-viewer-viu.git ~/.claude/skills/terminal-image-viewer-viu
chmod +x ~/.claude/skills/terminal-image-viewer-viu/scripts/*.sh
```

Claude Code picks up skills from `~/.claude/skills/` automatically. To have it used every time you do UI work, add a line like this to your `~/.claude/CLAUDE.md`:

```markdown
After every UI or Playwright screenshot, save it under `.playwright-mcp/` and show it with the terminal-image-viewer-viu skill.
```

## Use the scripts directly

```bash
# live preview of the newest .png in a folder
kitty --title "Screenshot preview" --detach scripts/viu-watch.sh ./screenshots

# compare images side by side
scripts/viu-grid.sh before.png after.png
scripts/viu-grid.sh -n 4 ./screenshots
```

Set `VIU=/path/to/viu` if viu is not on your `PATH` or in `~/.cargo/bin`.

## Notes and limits

- The preview checks the folder once a second and needs no file-watching tools.
- The grid is a snapshot and does not refresh.
- tmux before 3.3 cannot pass kitty images through, so viu inside tmux shows half-blocks. Use kitty splits (what the grid does).
- On some Ubuntu setups `/usr/bin/gnome-terminal` fails when launched from an agent's shell (`gi` import error); `/usr/bin/gnome-terminal.real` works. This only matters for the no-kitty fallback.
- The agent can confirm the preview process is running, not that you looked at it. The skill tells it not to claim otherwise.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to test a change, and look for issues labelled `good first issue` to get started.

## License

MIT, see [LICENSE](LICENSE).
