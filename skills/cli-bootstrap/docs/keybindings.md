# Kitty Keybindings — Quick Reference

## Pane Management

| Shortcut | Action |
|----------|--------|
| `Cmd+D` | Split vertically (side by side) |
| `Cmd+Shift+D` | Split horizontally (top/bottom) |
| `Cmd+]` | Focus next pane |
| `Cmd+[` | Focus previous pane |
| `Cmd+Shift+F` | Toggle zoom (fullscreen current pane) |
| `Cmd+W` | Close current pane |
| `Cmd+Shift+Right/Left` | Resize pane narrower/wider |
| `Cmd+Shift+Up/Down` | Resize pane taller/shorter |

## Tabs

| Shortcut | Action |
|----------|--------|
| `Cmd+T` | New tab (same working directory) |
| `Cmd+Shift+W` | Close tab |
| `Cmd+Shift+T` | Rename tab |
| `Cmd+1` through `Cmd+5` | Jump to tab N |
| `Cmd+Shift+]` | Next tab |
| `Cmd+Shift+[` | Previous tab |

## Display

| Shortcut | Action |
|----------|--------|
| `Cmd+=` | Increase font size |
| `Cmd+-` | Decrease font size |
| `Cmd+0` | Reset font size to default |
| `Ctrl+Shift+O` | Toggle glass mode (solid ↔ transparent) |
| `Ctrl+Shift+A, M` | Increase opacity +5% |
| `Ctrl+Shift+A, L` | Decrease opacity -5% |
| `Ctrl+Shift+A, 1` | Set opacity to 100% |
| `Ctrl+Shift+A, D` | Reset opacity to default |

## Other

| Shortcut | Action |
|----------|--------|
| `Cmd+C` | Copy to clipboard |
| `Cmd+V` | Paste from clipboard |
| `Cmd+/` | Show scrollback in bat/pager |
| `Cmd+N` | New window (same working directory) |
| `Cmd+Shift+R` | Reload config (colors only — restart for fonts) |

## Notes

- **Glass mode** (`Ctrl+Shift+O`): Toggles between solid (1.0) and transparent (0.88) opacity. Designed for dark wallpapers only — light backgrounds will reduce comment readability.
- **Font changes** require a full restart (`Cmd+Q` then reopen). `Cmd+Shift+R` only reloads colors and layout.
- **Scrollback** uses bat as the pager — supports syntax highlighting and search.
