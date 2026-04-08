# System Monitor (btop)

## What

Beautiful TUI system monitor with braille-character graphs. Shows CPU, memory, disk, and network in real-time with smooth, high-resolution visualizations.

## Why btop

- Single binary, zero config needed out of the box
- Braille graphs are denser and more readable than ASCII block charts
- Per-core CPU usage, process tree, disk I/O, network throughput all in one view
- Vim keybindings (hjkl navigation)
- Theme support -- built-in themes or custom

## Installation

Install via brew (`brew install btop`) or native package manager. Available in most distro repos.

## Config

Config lives at `~/.config/btop/btop.conf`.

Key settings:
- **Theme:** set `color_theme` to match terminal theme. Btop ships with many built-in themes.
- **Update interval:** default 2000ms is fine. Lower for more responsive graphs at slight CPU cost.
- **Vim keys:** `vim_keys = true`
- **Rounded corners:** `rounded_corners = true` for a softer look in terminals that support box-drawing characters
