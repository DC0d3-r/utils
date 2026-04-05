# Tool Choices — Why These Specific Tools

This document explains the reasoning behind each tool selection. Every choice was evaluated against alternatives — here's the thinking.

## Terminal Emulator: Kitty

| Option | Pros | Cons |
|--------|------|------|
| **Kitty** (chosen) | GPU-accelerated, cross-platform, image protocol, Python scriptable, splits+tabs, cursor trails, active dev | Config can be verbose, no GUI settings |
| iTerm2 | Rich GUI, macOS-native feel, good search | macOS only, no Linux, heavier memory |
| Alacritty | Fastest rendering, minimal | No tabs, no splits (need tmux), no images |
| WezTerm | Good features, multiplexer built-in | Lua config is verbose, less community |
| Ghostty | Native platform feel, fast | Newer project, smaller ecosystem |

**Decision:** Kitty wins on the combination of cross-platform + image protocol (for the greeter) + Python scripting (custom tab bar, opacity toggle) + cursor trails. If you're macOS-only and prefer a GUI settings panel, iTerm2 is a fine choice.

## Prompt: Starship

| Option | Pros | Cons |
|--------|------|------|
| **Starship** (chosen) | Rust-fast, any shell, TOML config, modular, palette support | Less customizable than P10k for extreme tweaks |
| Powerlevel10k | Very fast, instant prompt, deep git integration | Zsh-only, complex wizard, framework dependency |
| Oh My Zsh themes | Huge theme library, batteries included | Slow startup, loads unused plugins, zsh-only |
| pure | Minimal, fast, clean | Limited modules, less information |

**Decision:** Starship's cross-shell support (works in zsh, bash, fish), TOML config (human-readable), and native palette system (for theme switching) made it the clear winner. If you only use zsh and want maximum git status detail, P10k is also excellent.

## Diff Viewer: Delta

| Option | Pros | Cons |
|--------|------|------|
| **Delta** (chosen) | Syntax highlighting, side-by-side, line numbers, git integration | Requires terminal with good color support |
| diff-so-fancy | Better than raw diff, easy setup | No syntax highlighting, single-column only |
| difftastic | Structural (AST) diffs, language-aware | Different paradigm, can be confusing for simple diffs |

**Decision:** Delta provides the best balance of beauty and utility. Side-by-side mode makes reviewing diffs dramatically faster. Syntax highlighting means you see the diff in the context of actual code, not raw text.

## System Monitor: Btop

| Option | Pros | Cons |
|--------|------|------|
| **Btop** (chosen) | Beautiful graphs, custom themes, braille resolution, vim keys | Slightly higher overhead than htop |
| htop | Universal, lightweight, simple | No graphs, no themes, basic UI |
| glances | Web UI option, many sensors | Python, heavier, busy UI |
| bottom | Rust, good defaults | Less customizable themes |

**Decision:** Btop's braille graphs and theme support are unmatched. The Wavefront theme maps CPU temperature to a green→yellow→red gradient that's both beautiful and informative.

## File Listing: Eza (replaces ls)

| Option | Pros | Cons |
|--------|------|------|
| **Eza** (chosen) | Icons, git status, tree view, color themes | Extra dependency |
| ls | Always available, no setup | No icons, no git, no tree, no colors |
| lsd | Icons, colors | Less active development than eza |
| exa | Original eza fork | Unmaintained (eza is the successor) |

**Decision:** Eza adds visual information density — see file types, git status, and directory structure at a glance. The `ll` alias (long format, relative timestamps, no permissions) is the most-used command.

## File Search: fd (replaces find)

| Option | Pros | Cons |
|--------|------|------|
| **fd** (chosen) | Simple syntax, fast, respects .gitignore | Different syntax from find |
| find | Universal, powerful expressions | Verbose syntax, searches everything |
| locate/mlocate | Instant (pre-indexed) | Stale index, not real-time |

**Decision:** `fd pattern` vs `find . -name "*pattern*"`. The syntax improvement alone is worth it. Respecting .gitignore means you never search through node_modules by accident.

## Text Search: Ripgrep (replaces grep)

| Option | Pros | Cons |
|--------|------|------|
| **Ripgrep** (chosen) | 10x faster than grep, respects .gitignore, better defaults | Different flags from grep |
| grep | Universal, POSIX standard | Slow on large codebases, no .gitignore |
| ag (silver searcher) | Fast, .gitignore support | Ripgrep is faster and more actively maintained |

**Decision:** Ripgrep is objectively faster and has better defaults (recursive by default, .gitignore respect, smart case). There's no downside except muscle memory for grep flags.

## File Viewer: Bat (replaces cat)

| Option | Pros | Cons |
|--------|------|------|
| **Bat** (chosen) | Syntax highlighting, line numbers, git integration, paging | Extra dependency |
| cat | Universal, zero setup | No highlighting, no line numbers |
| less | Paging, search | No syntax highlighting |

**Decision:** Bat is a strict superset of cat — everything cat does, plus syntax highlighting and line numbers. The `--paging=never` alias makes it behave like cat by default; `catp` alias enables the pager.

## Fuzzy Finder: FZF

No alternatives considered — FZF is the undisputed king of fuzzy finding. It powers:
- `Ctrl-R` for history search (replaces the default reverse-i-search)
- `Ctrl-T` for file path insertion
- `Alt-C` for directory jumping
- Custom functions (fcd, fv) for directory navigation and file preview

## Smart CD: Zoxide

| Option | Pros | Cons |
|--------|------|------|
| **Zoxide** (chosen) | Learns habits, fast, cross-shell | Needs time to learn your directories |
| autojump | Similar concept, older | Slower, Python, less maintained |
| z.lua | Lua implementation | Less maintained than zoxide |
| fasd | Frequency + recency | Unmaintained |

**Decision:** Zoxide is the modern, maintained version of the "frecency-based cd" concept. After a few days of use, `z proj` takes you to `~/code/project` without thinking.

## Fonts: IosevkaTerm NF + Monaspace Radon NF

**Primary (IosevkaTerm):** Chosen for its narrow glyphs (more columns in splits), clean geometry, and Japanese-like vertical rhythm that matches the Wavefront aesthetic. The Nerd Font variant adds terminal icons.

**Italic (Monaspace Radon):** A handwritten-texture italic that makes comments visually distinct from code. The texture change (geometric → handwritten) creates stronger visual separation than just slanting the same font.

| Alternative | Why not |
|-------------|---------|
| JetBrains Mono | Wider glyphs = fewer columns, less breathing room |
| Fira Code | Rounder shapes conflict with the geometric Wavefront identity |
| Cascadia Code | Good but tied to Microsoft ecosystem feel |
| Victor Mono | Cursive italic is too dramatic for 8-hour sessions |
