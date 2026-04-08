# Theme Mapping — Built-in Terminal Themes

When the target terminal has built-in themes, use them instead of manually defining colors.
Only define colors manually as a fallback.

## Ghostty (460+ built-in themes)

| Wavefront Theme | Ghostty Built-in | Notes |
|---|---|---|
| wavefront | `Kanagawa Wave` | Exact match — same palette origin |
| tokyo-night | `TokyoNight Storm` | Storm variant is closest to our dark version |
| catppuccin-mocha | `Catppuccin Mocha` | Exact match |
| rose-pine | `Rose Pine` | Exact match. Also: `Rose Pine Moon` (darker) |
| glassmind | `Nord` | Closest vibe — minimal, cool monochromatic |
| neon-depths | `Dracula` | Closest high-saturation dark theme |

Usage: `theme = Kanagawa Wave` in Ghostty config. One line, done.

## Kitty (no built-in themes)

Kitty requires manual color definitions. Use the hex values from `design/colors.md` or the palette docs in each theme's directory.

## WezTerm

WezTerm has built-in color schemes. Use `color_scheme = "Kanagawa (Gogh)"` or similar.

## Terminal-Agnostic Tools

These tools need colors set regardless of terminal:

| Tool | How to theme |
|---|---|
| FZF | `FZF_DEFAULT_OPTS` with `--color` flags — translate palette hex values |
| Starship | Palette block in `starship.toml` — use named palette colors |
| Delta | `syntax-theme = ansi` respects terminal colors automatically |
| Btop | Custom `.theme` file or use built-in themes |
| Bat | `BAT_THEME=ansi` to inherit terminal colors |
| Eza | `EZA_COLORS` env var for file type colors |
