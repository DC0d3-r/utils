# Shell Configuration

## Structure

Create a single config file (`wavefront.bash` or `wavefront.zsh`) that gets sourced from the user's rc file. This keeps customizations isolated and portable.

**Guard against double-sourcing:**
```
# At the top of the file, check for a sentinel env var.
# If set, return early. If not, set it and continue.
```

## Aliases

Every alias MUST be guarded with `command -v` so it only activates if the replacement tool is installed. Never break a user's shell because a tool is missing.

| Alias | Target | Flags |
|-------|--------|-------|
| `ls` | `eza` | `--icons --group-directories-first` |
| `ll` | `eza` | `--icons --group-directories-first -la` |
| `lt` | `eza` | `--icons --tree --level=2` |
| `cat` | `bat` | `--paging=never` (inline, no scrolling) |
| `grep` | `rg` | (smart case by default) |
| `find` | `fd` | (simpler syntax) |

## FZF Integration

FZF provides three shell keybindings:
- **Ctrl+R** -- fuzzy history search
- **Ctrl+T** -- fuzzy file finder (insert path at cursor)
- **Alt+C** -- fuzzy cd into directory

Configure:
- Default command: `fd --type f --hidden --exclude .git` (fast, respects .gitignore)
- File preview: `bat --style=numbers --color=always {}`
- Directory preview: `eza --tree --level=2 --icons {}`
- Colors: match the selected theme via FZF_DEFAULT_OPTS color flags

## Zoxide

Smart `cd` replacement that learns from usage. Init with:
```
eval "$(zoxide init $SHELL_NAME)"
```
This provides `z` as a frecency-based jump command.

## Git Aliases

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `gs` | `git status -sb` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `glog` | `git log --oneline --graph --decorate` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |

## Navigation

| Alias | Action |
|-------|--------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |

## Functions

- **mkcd**: Create directory and cd into it in one command
- **extract**: Universal archive extractor -- detect format (.tar.gz, .zip, .7z, .xz, etc.) and call the right tool
- **fcd**: Combine zoxide query with fzf selection for interactive directory jump
- **fv**: fzf file finder with bat preview, opens selection in $EDITOR

## Tool Theme Variables

Set these environment variables to keep tool colors consistent with the chosen theme:

- `BAT_THEME` -- bat's syntax highlighting theme
- `LS_COLORS` / `EZA_COLORS` -- file type coloring
- `LESS_TERMCAP_*` -- man page colors (bold, underline, standout). Set these so man pages get colored headings and highlights instead of raw escape codes.

## Zsh Warning

In zsh, `path` is a special array variable tied to `PATH`. Never use `path` as a local variable name -- it will silently break your PATH and cause confusing command-not-found errors.
