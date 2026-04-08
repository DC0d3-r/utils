# CLI Bootstrap — Terminal Style Guide

A design reference for setting up a beautiful, modern terminal environment.
Japanese woodblock-inspired aesthetic, modern CLI tools, and the reasoning behind every choice.

## What Is This?

This is a **style guide for Claude Code** (or any AI coding agent). It's not a script to run — it's a collection of design docs that describe:

- What the terminal environment should look and feel like
- Which tools to use and why
- Color palette principles and values
- Typography and spacing philosophy
- Keybinding conventions

Claude reads these docs, understands the system it's on, and generates appropriate configs.

## How to Use

1. Open Claude Code in this directory
2. Ask: "Set up my terminal using this style guide"
3. Claude detects your OS, shell, terminal, and package manager
4. Claude installs tools and generates configs adapted to your system

## What You Get

- **GPU-accelerated terminal** (Kitty, Ghostty, or WezTerm — whichever fits your system)
- **Starship prompt** with git status, transient prompt, and theme colors
- **Modern CLI tools** — bat, eza, fd, ripgrep, fzf, zoxide replacing cat, ls, find, grep
- **Delta** for beautiful side-by-side git diffs
- **Lazygit** TUI for git operations
- **Btop** system monitor
- **6 color themes** — Wavefront, Tokyo Night, Catppuccin, Rose Pine, Glassmind, Neon Depths

## Structure

```
CLAUDE.md              ← Start here (Claude's entry point)
design/                ← Aesthetic principles
  philosophy.md        ← The "why" — Japanese aesthetic, negative space
  colors.md            ← Palette with hex values, contrast ratios
  typography.md        ← Font choices and spacing principles
  keybindings.md       ← Keybinding conventions
tools/                 ← Tool selection and setup guidance
  terminal.md          ← Terminal emulator recommendations
  prompt.md            ← Starship prompt setup
  shell-config.md      ← Aliases, functions, FZF theme
  git.md               ← Delta, lazygit, git aliases
  cli-replacements.md  ← bat, eza, fd, ripgrep, fzf, zoxide
  system-monitor.md    ← btop
themes/                ← Color theme references
  theme-mapping.md     ← Maps themes to built-in terminal themes
  wavefront/           ← Default theme palette
  tokyo-night/         ← Cool blue-purple
  catppuccin-mocha/    ← Warm pastels
  rose-pine/           ← Muted elegance
reference/             ← Lessons learned
  bazzite-notes.md     ← Gotchas from immutable OS deployment
```

## Legacy Code

The `setup.sh`, `lib/`, `modules/`, and `configs/` directories contain the original prescriptive bash scripts. They are kept for reference but **should not be executed**. The style guide docs in `design/` and `tools/` supersede them.
