# Contributing

Thanks for helping. Bug reports, fixes and new terminal support are all welcome.

## Before you start

- **Small fix** (typo, clearer docs, an obvious bug): open a pull request straight away.
- **Anything bigger** (a new script, a new terminal, a change to how the skill tells the agent to behave): open an issue first so we can agree on the approach.
- Issues labelled [`good first issue`](../../labels/good%20first%20issue) are a good place to begin.

## What lives where

| File | What it is |
|---|---|
| `SKILL.md` | Instructions the agent reads. Keep it short and concrete; every rule should say what to do, not just what to avoid. |
| `scripts/viu-watch.sh` | Live preview: shows the newest `.png` in a folder and redraws on change. |
| `scripts/viu-grid.sh` | Opens several images side by side in one kitty window. |
| `README.md` | For humans: the problem, install, usage, limits. |

## Ground rules for the scripts

- bash only, no new dependencies beyond viu and kitty. Code must work with both GNU and BSD/macOS tools.
- Fail with a clear message when viu, kitty or the images are missing.
- Never write into the agent's own terminal, and never use `pkill -f` on the script name (it matches the caller's shell).

## Test your change

There is no automated display test, so please test by hand and say what you ran in the pull request.

1. Lint (CI runs the same):
   ```bash
   shellcheck -S warning scripts/*.sh
   ```
2. Preview window: open it, then add a new `.png` to the folder and check it redraws within a second, and again when you resize the window:
   ```bash
   kitty --title "Screenshot preview" --detach scripts/viu-watch.sh /tmp/shots
   ```
3. Grid: `scripts/viu-grid.sh -n 3 /tmp/shots` and `scripts/viu-grid.sh a.png b.png`.
4. If you changed `SKILL.md`, install your copy into `~/.claude/skills/terminal-image-viewer-viu`, ask Claude Code to take and show a screenshot, and check it follows the new instructions.

Mention your OS, terminal, and viu and kitty versions (`viu --version`, `kitty --version`).

## Pull requests

- One change per pull request, with a short description of the problem and the fix.
- Update `README.md` or `SKILL.md` when behaviour changes.
- By contributing you agree your work is released under the [MIT License](LICENSE).
