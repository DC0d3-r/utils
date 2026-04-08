# Modern CLI Replacements

## Overview

These tools replace standard Unix utilities with faster, more featureful alternatives. All are single-binary installs with no runtime dependencies.

## Tools

### bat (replaces cat)

Syntax highlighting, line numbers, git diff markers. Strict superset of cat -- existing scripts won't break.

- Use `--paging=never` when used as an alias for `cat` (inline output, no scrolling)
- Supports custom themes via `bat --list-themes`
- Set `BAT_THEME` env var for consistent theming

### eza (replaces ls)

Icons (requires Nerd Font), git status column, tree view, color themes.

- `--group-directories-first` -- directories before files, always
- `--icons` -- file type icons via Nerd Font glyphs
- `--tree` -- recursive tree view (replaces `tree` command)
- `--git` -- show git status per file

### fd (replaces find)

Simple syntax: `fd pattern` instead of `find . -name "*pattern*"`. 5-10x faster, respects `.gitignore` by default.

- Use `--hidden` to include dotfiles
- Use `--no-ignore` to search gitignored files
- **Debian/Ubuntu note:** installs as `fdfind` -- create a symlink or alias to `fd`

### ripgrep (replaces grep)

10x faster than grep, respects `.gitignore`, smart case (case-insensitive unless you use uppercase), structured output.

- Binary is `rg`
- Use `--hidden` to search dotfiles
- Use `--no-ignore` to search gitignored files
- Supports PCRE2 regex with `--pcre2`

### fzf (fuzzy finder)

Not a replacement -- an enhancer. Provides fuzzy matching on any list input (files, history, processes, git branches).

- Shell integration: Ctrl+R (history), Ctrl+T (files), Alt+C (cd)
- Pipe anything into it: `git branch | fzf`, `ps aux | fzf`
- Preview support: show file contents or directory trees alongside the selection list

### zoxide (replaces cd)

Learns which directories you visit and how often. `z foo` jumps to the highest-frecency directory matching "foo".

- Init: `eval "$(zoxide init bash)"` (or zsh, fish)
- Provides `z` (jump) and `zi` (interactive jump with fzf)
- Data stored in `~/.local/share/zoxide/db.zo`

## Installation

Prefer **brew** (`brew install bat eza fd ripgrep fzf zoxide`) for consistency across Linux and macOS. Fall back to native package manager if brew isn't available.

On immutable Linux distros (Bazzite, Silverblue), use brew or install into a toolbox/distrobox container.
