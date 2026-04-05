# CLI Bootstrap — The Wavefront Terminal Experience

> A complete CLI environment setup: Japanese woodblock-inspired theme,
> modern tools, and the reasoning behind every choice.

## What You Get

A fully themed, GPU-accelerated terminal with:
- **Kitty** terminal with cursor trails, custom tab bar, opacity toggle
- **Starship** prompt with git status, tool versions, transient prompt
- **Delta** for beautiful side-by-side git diffs in theme colors
- **Lazygit** TUI with matching color hierarchy
- **Btop** system monitor with gradient graphs
- **Modern CLI** — bat, eza, fd, ripgrep, fzf, zoxide (replacing cat, ls, find, grep)
- **Themed FZF** fuzzy finder for files, history, directories
- **Ensō koi greeter** displayed on each new shell via Kitty image protocol
- **6 color themes** — swap with a single command

## Quick Start

```bash
# Interactive walkthrough (recommended for first time)
./setup.sh

# Install everything, no prompts
./setup.sh --all --yes

# Just install specific tools
./setup.sh --module fonts,kitty,starship
```

## Themes

Six pre-built color themes. Switch anytime:

```bash
./setup.sh --themes            # Browse available themes
./setup.sh --theme rose-pine   # Switch themes
```

| Theme | Vibe | Best For |
|-------|------|----------|
| **wavefront** (default) | Japanese woodblock, warm muted | Daily driving, long coding sessions |
| **neon-depths** | Cyberpunk, cool purple | Incident response, operations |
| **glassmind** | Translucent minimal, gray-violet | Aesthetic screenshots |
| **tokyo-night** | Cool blue-purple | Familiar ecosystem, wide plugin support |
| **catppuccin-mocha** | Warm pastel | Comfort, consistency across 400+ apps |
| **rose-pine** | Soho vibes, pastel accents | Elegance, soft on the eyes |

Each theme provides coordinated colors for all tools — kitty, starship, delta, lazygit, btop, fzf, and zsh syntax highlighting.

## Modules

The setup is split into 9 independent modules. Each one:
1. **Explains** what the tool is and why it's worth using
2. **Shows alternatives** and why this choice was made
3. **Installs** the tool (brew on macOS, apt/pacman on Linux)
4. **Configures** it with the selected theme
5. **Verifies** the installation

| # | Module | What it does |
|---|--------|-------------|
| 01 | `fonts` | Nerd Fonts — IosevkaTerm (primary) + Monaspace Radon (italic) |
| 02 | `kitty` | GPU-accelerated terminal with splits, tabs, image support |
| 03 | `starship` | Cross-shell prompt — git status, tool versions, fast |
| 04 | `zsh` | Shell plugins + Wavefront theme (aliases, functions, highlights) |
| 05 | `git-delta` | Syntax-highlighted side-by-side git diffs |
| 06 | `lazygit` | Full git TUI — stage hunks, rebase, cherry-pick |
| 07 | `btop` | System monitor — CPU, memory, disk, network graphs |
| 08 | `cli-tools` | bat, eza, fd, ripgrep, fzf, zoxide |
| 09 | `greeter` | Ensō koi artwork on terminal startup |

Run individually: `./setup.sh --module kitty`

## The Full Story — Why These Tools?

### Terminal: Kitty

**What:** GPU-accelerated terminal emulator with image rendering, splits, tabs, and Python scripting.

**Alternatives considered:**
- **iTerm2** — macOS only, no Linux, heavier resource usage
- **Alacritty** — Fast but no tabs, no images, no splits (need tmux)
- **WezTerm** — Good features but Lua config is verbose for what we need
- **Ghostty** — Promising newcomer, but younger ecosystem

**Why Kitty:** Cross-platform, GPU-rendered, native image protocol (for the greeter), Python-scriptable tab bar and kittens (custom commands), cursor trails, active development. It's the sweet spot of features vs. complexity.

### Prompt: Starship

**What:** Cross-shell prompt written in Rust. Configured via TOML.

**Alternatives considered:**
- **Oh My Zsh themes** — Slow (loads everything), zsh-only, framework lock-in
- **Powerlevel10k** — Fast but complex config wizard, zsh-only
- **pure** — Minimal and clean, but limited modules

**Why Starship:** Works in any shell (zsh, bash, fish), fast (Rust), TOML config (readable), modular (show only what's relevant), supports custom palettes for theming.

### Diff Viewer: Delta

**What:** Syntax-highlighted git diff viewer with side-by-side mode.

**Alternatives considered:**
- **diff-so-fancy** — Better than raw diff, but no syntax highlighting
- **difftastic** — Structural diffs (AST-based), but different paradigm

**Why Delta:** Side-by-side by default, line numbers, syntax highlighting, hunk navigation (n/N), integrates seamlessly with git (just set core.pager).

### System Monitor: Btop

**What:** Terminal-based system monitor with graphs, themes, vim keys.

**Alternatives considered:**
- **htop** — Simpler, no graphs, fewer metrics
- **glances** — Python, heavier, web UI mode
- **bottom/zenith** — Rust alternatives, less mature

**Why Btop:** Beautiful braille graphs, customizable layouts, theme support, low overhead. The Wavefront theme maps CPU/temp/memory gradients to green→yellow→red.

### CLI Replacements

| Old | New | Why |
|-----|-----|-----|
| `cat` | `bat` | Syntax highlighting, line numbers, git integration |
| `ls` | `eza` | Icons, git status, tree view, color-coded |
| `find` | `fd` | Simpler syntax, faster, respects .gitignore |
| `grep` | `ripgrep` | 10x faster, respects .gitignore, sane defaults |
| — | `fzf` | Fuzzy finder for everything (Ctrl-R, file picker) |
| `cd` | `zoxide` | Learns your habits, `z project` jumps to ~/code/project |

## How It Works

### Config Strategy
- **Symlinks** for standalone configs (kitty, starship, lazygit, btop) — edit in the repo, reflected everywhere
- **[include]** directive for .gitconfig — delta config lives in its own file, your user.name/email untouched
- **Source line** for .zshrc — Wavefront additions live in `~/.config/wavefront/wavefront.zsh`, your PATH/NVM/etc. stays untouched

### Backups
Before touching any config, the script creates a timestamped backup:
```
~/.config-backups/cli-bootstrap/
  2026-04-04_153022/
    manifest.txt       # What was backed up and why
    kitty.conf         # Original config
    starship.toml
    ...
```

Restore anytime: `./setup.sh --restore 2026-04-04_153022`

### Cross-Platform
Detects macOS (Homebrew) and Linux (apt/pacman). Handles platform differences:
- Fonts: brew cask on macOS, GitHub release downloads on Linux
- fd package: `fd` on brew, `fd-find` on apt (different binary name)
- Plugin paths: `/opt/homebrew/share/` on macOS vs `/usr/share/` on Linux

## Customization

### Changing fonts
Edit `configs/kitty/kitty.conf` — the `font_family` and `italic_font` lines. Restart kitty (Cmd+Q) after font changes.

### Creating a custom theme
1. Copy an existing theme directory: `cp -r themes/wavefront themes/my-theme`
2. Edit the color values in each file
3. Update `palette.md` with your color names
4. Apply: `./setup.sh --theme my-theme`

### Modifying the prompt
Edit `configs/starship.toml`. Changes are picked up on the next prompt render (instant). See [starship.rs/config](https://starship.rs/config/) for all options.

## Keybindings (Kitty)

| Shortcut | Action |
|----------|--------|
| `Cmd+D` | Split vertically |
| `Cmd+Shift+D` | Split horizontally |
| `Cmd+]` / `Cmd+[` | Focus next/previous pane |
| `Cmd+Shift+F` | Zoom current pane (fullscreen) |
| `Cmd+T` | New tab |
| `Cmd+W` | Close pane |
| `Cmd+1-5` | Go to tab N |
| `Cmd+=/−` | Increase/decrease font size |
| `Cmd+/` | Show scrollback in bat |
| `Cmd+Shift+R` | Reload config |
| `Ctrl+Shift+O` | Toggle glass mode (transparency) |

## Troubleshooting

**Fonts not rendering (tofu/boxes):** Restart kitty completely (Cmd+Q, not just Cmd+Shift+R). Font changes require a full restart.

**SSH sessions look wrong:** The `ssh` alias sets `TERM=xterm-256color` automatically. If colors are still off, the remote server may not have the terminfo — run `kitty +kitten ssh` instead for full support.

**Background texture missing:** Run `./assets/backgrounds/generate-noise.sh`. Requires ImageMagick.

**Green and cyan look the same:** This is the hue separation fix — waveAqua was shifted from H:165 to H:180 to create a 35° gap from green. If they still look similar on your display, try the neon-depths theme which has wider hue separation.

**Greeter image not showing:** The greeter only works inside Kitty (uses kitten icat). It's automatically skipped in VSCode terminal, Emacs, and SSH sessions.
