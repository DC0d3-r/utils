# CLI Bootstrap — Style Guide for Claude

This skill guides you in setting up a beautiful, modern terminal environment.
It is a **design reference**, not a script. Read the docs, understand the intent, then adapt to the target system.

**Do NOT run `setup.sh` or copy config files from this repo.** Generate configs native to the target system.

## Before You Start

Detect the environment before making any decisions:

1. **OS**: `cat /etc/os-release` — check both `ID` and `ID_LIKE`
2. **Immutable?**: `test -f /run/ostree-booted` — if yes, avoid native package managers (dnf, apt)
3. **Package manager**: prefer `brew` (if available) > `flatpak` (for GUI apps) > native pkg manager > official installer scripts
4. **Shell**: `echo $SHELL` — enhance the user's current shell. **Never switch shells.**
5. **Terminal**: check what's running. Recommend a GPU-accelerated terminal but **ask first, don't force one**
6. **Desktop environment**: KDE, GNOME, etc. — affects blur, transparency, desktop integration

## Install Strategy

| System Type | CLI Tools | GUI Apps | Avoid |
|---|---|---|---|
| Standard Linux (Ubuntu, Fedora, Arch) | native pkg manager or brew | native pkg manager or flatpak | — |
| Immutable Linux (Bazzite, Silverblue, Kinoite) | `brew` | flatpak > AppImage > rpm-ostree | `dnf install`, `apt install` |
| macOS | `brew` | `brew --cask` | — |

## Anti-Patterns — DO NOT

- **Copy/symlink config files from this repo** — the user may delete the repo. Generate configs in `~/.config/`
- **Force a shell switch** — if the user is on bash, write bash config. Don't install zsh "because the skill says so"
- **Use terminal-specific features without checking** — cursor trails, image protocols, kittens are terminal-dependent
- **Hardcode paths** — detect where brew, plugins, fonts live on this system
- **Define color palettes manually when built-in themes exist** — Ghostty has 460+ built-in themes, use them
- **Run the setup.sh script** — it's legacy code, kept for reference only
- **Use zsh special variable names in scripts** — `path`, `fpath`, `cdpath`, `manpath` are tied arrays in zsh and will destroy PATH

## What to Set Up

Read the docs in this order:

1. **`tools/terminal.md`** — pick and configure a terminal emulator
2. **`design/`** — understand the aesthetic (colors, typography, spacing)
3. **`tools/cli-replacements.md`** — install modern CLI tools (bat, eza, fd, rg, fzf, zoxide)
4. **`tools/prompt.md`** — set up starship prompt
5. **`tools/shell-config.md`** — wire up aliases, functions, FZF theme in the user's shell
6. **`tools/git.md`** — configure delta for diffs, lazygit
7. **`tools/system-monitor.md`** — btop
8. **`themes/`** — pick a color theme

## Config Generation Guidelines

- **Terminal config**: use the terminal's native config format. Use built-in themes when available.
- **Shell config**: create a single file (`wavefront.bash` or `wavefront.zsh`) sourced from the user's rc file. One source line, easily removable.
- **Git config**: use `[include]` directives — never overwrite `.gitconfig`
- **All configs**: should be self-contained in `~/.config/wavefront/` or the tool's own config dir
