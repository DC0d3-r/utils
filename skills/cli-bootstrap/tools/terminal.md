# Terminal Emulator

## Goal

A GPU-accelerated terminal with image protocol support, splits/tabs, and deep configurability. The terminal is the primary interface -- it should be fast, beautiful, and functional.

## Options

| Terminal | Language | Strengths | Notes |
|----------|----------|-----------|-------|
| **Kitty** | Python/C | Mature, pioneer of kitty image protocol, cursor trails via shaders, Python-scriptable extensions | No Flatpak. Install via native pkg or binary. |
| **Ghostty** | Zig | Fastest rendering, custom shader support, huge built-in theme library (~300+), native platform feel | Newer. AppImage available. |
| **WezTerm** | Rust | Lua config, built-in multiplexer (splits/tabs without tmux), cross-platform | Heavier than the others. |

## Selection

Don't force a choice. Check what's installable on the target OS and recommend based on availability. Ask the user which they prefer.

- Check native package manager first, then Flatpak/AppImage/binary
- Kitty lacks Flatpak; Ghostty has AppImage; WezTerm has broad packaging
- If the user has no preference, lean toward Ghostty (speed) or Kitty (ecosystem maturity)

## Visual Config

These settings apply regardless of which terminal is chosen -- translate to the appropriate config format:

- **Transparency:** 0.90-0.95 opacity for subtle glass effect. Don't go lower -- readability matters.
- **Padding:** 8-12px on all sides. Gives the content room to breathe.
- **Cursor:** Block style, no blink. Blinking is distracting in a coding terminal.
- **Cursor trail/shader:** Enable if available (Kitty cursor_trail, Ghostty custom shaders). Subtle glow or fade effect.
- **Font:** Requires a Nerd Font for icons in eza, starship, etc. Use whatever the user has or install one.

## Desktop Integration

Ensure a `.desktop` file exists so the terminal appears in the app launcher. Most package managers handle this, but manual/binary installs may not. Check `~/.local/share/applications/` or `/usr/share/applications/`.
