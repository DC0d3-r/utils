# Starship Prompt

## Why Starship

- Cross-shell: works identically in bash, zsh, fish, nushell
- Rust-fast: no perceptible delay even with git status on large repos
- TOML config at `~/.config/starship.toml`
- Modular: each info segment is an independent module

## Init

Add to the user's shell rc file (`.bashrc`, `.zshrc`, etc.):

```
eval "$(starship init bash)"   # or zsh, fish, etc.
```

## What to Show

- **Directory:** truncated to 3 components, repo root highlighted
- **Git:** branch name + status indicators (staged, modified, untracked, ahead/behind)
- **Language versions:** Python, Node, Rust, Go -- but ONLY when a relevant file exists in the current directory (e.g., show Python version only when `*.py`, `pyproject.toml`, etc. are present). Starship does this by default -- don't disable the detection.
- **Command duration:** show execution time for commands > 2 seconds
- **Exit status:** show non-zero exit codes

## Transient Prompt

After a command executes, collapse the previous prompt to just `>`. This dramatically reduces visual noise when scrolling through history.

Starship doesn't natively support transient prompts -- this requires shell-level integration:
- **Zsh:** use `zle-line-init` hook to redraw previous prompt
- **Bash:** use `PROMPT_COMMAND` or `DEBUG` trap
- **Fish:** use `fish_postexec`

The implementation varies by shell. Generate the appropriate hook for the user's shell.

## Palettes

Starship supports `[palettes]` -- define named color sets and reference them via `palette = "name"` at the top level. This lets you swap the entire prompt's color scheme without editing individual modules.

Define a palette that matches the user's chosen terminal/editor theme.
