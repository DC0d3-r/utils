# Git Tooling

## Delta (diff pager)

Delta replaces git's default pager with syntax-highlighted, side-by-side diffs.

### Integration

Add delta config via `[include]` in the user's `.gitconfig` -- **never overwrite** existing gitconfig content. Create a separate delta config file and include it.

### Settings

- `navigate = true` -- use n/N to jump between diff sections
- `side-by-side = true` -- two-column diff view
- `line-numbers = true` -- show line numbers in both columns
- `syntax-theme = ansi` -- use terminal's ANSI colors so delta matches the terminal theme automatically

### Relevant gitconfig sections

```
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
    syntax-theme = ansi

[merge]
    conflictstyle = zdiff3
```

## Lazygit

TUI for git operations. Faster than CLI for:
- Staging individual hunks/lines
- Interactive rebase (reorder, squash, edit)
- Cherry-picking between branches
- Browsing commit history and diffs

### Config

Config lives at `~/.config/lazygit/config.yml`.

Key settings:
- Use delta as the pager (so diffs look identical to CLI)
- Enable mouse support
- Set theme colors to match terminal theme

## Git Aliases

Shell-level git aliases (gs, ga, gc, etc.) are defined in `shell-config.md`. These are shell aliases, not git aliases in gitconfig -- they're faster to type and easier to manage.
