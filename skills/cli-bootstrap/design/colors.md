# Wavefront: Color Palette

Based on Kanagawa (Wave variant). All accents tuned in Okhsl for perceptual uniformity.

## Design Constraints

- **Color space:** Okhsl -- perceptually uniform lightness and saturation
- **Contrast:** WCAG AA minimum (4.5:1 for body text, 3:1 for large/UI elements)
- **Undertone:** Warm neutral with indigo bias (base hue ~260)
- **Rule:** No accent color should visually dominate another at equal semantic weight

## Background Ramp

From deepest to lightest. Primary surface is Sumi.

| Name    | Hex       | Usage                          |
|---------|-----------|--------------------------------|
| Void    | `#111117` | Deepest background, dimmed UI  |
| Ink     | `#16161D` | Secondary panels, statuslines  |
| Sumi    | `#1F1F28` | **Primary background**         |
| Stone   | `#2A2A37` | Selection, visual highlight    |
| Pebble  | `#363646` | Active line, hover             |
| Drift   | `#44445B` | Borders, separators            |
| Mist    | `#54546D` | Inactive text, line numbers    |
| Fog     | `#65657A` | Placeholder text               |

## Foreground Ramp

| Name      | Hex       | Usage                               | Contrast vs Sumi |
|-----------|-----------|-------------------------------------|-------------------|
| Ash       | `#727169` | Comments, disabled                  | ~4.6:1            |
| Clay      | `#938E7E` | Secondary text                      | ~6.5:1            |
| Parchment | `#C8C093` | UI labels, parameters               | ~9.5:1            |
| Ivory     | `#DCD7BA` | **Primary foreground**              | ~12:1             |
| Silk      | `#EDEAD5` | Bright/emphasized text              | ~14:1             |

## ANSI Normal (L:0.70, S:0.35-0.50)

| Color   | Hex       |
|---------|-----------|
| Red     | `#D0605A` |
| Green   | `#7BA888` |
| Yellow  | `#C4B28A` |
| Blue    | `#7E9CD8` |
| Magenta | `#957FB8` |
| Cyan    | `#6DB5A8` |

## ANSI Bright (L:0.80, S:0.42-0.55)

| Color   | Hex       |
|---------|-----------|
| Red     | `#E8685E` |
| Green   | `#8FBF96` |
| Yellow  | `#DEB97D` |
| Blue    | `#7FB4CA` |
| Magenta | `#B09FD6` |
| Cyan    | `#82CCBE` |

## Semantic Usage

| Color   | Meaning                                  |
|---------|------------------------------------------|
| Red     | Errors, deletions, destructive actions   |
| Green   | Success, additions, confirmations        |
| Yellow  | Warnings, globs, pending states          |
| Blue    | Cursor, info, paths, links               |
| Magenta | Keywords, branches, special identifiers  |
| Cyan    | Strings, values, secondary info          |

## Applying This Palette

**Prefer built-in themes.** If a tool ships with a Kanagawa theme (kitty, neovim, bat, lazygit, etc.), use it directly. Don't redefine hex values that the theme already provides.

**FZF and similar tools** that take inline color flags: translate the palette above into the tool's flag format. Map semantic roles (fg, bg, hl, pointer, marker) to the appropriate ramp values.

**Tools without theme support:** Set what you can (usually fg/bg and a handful of accents). Don't force full theming where the tool resists it -- a partially-themed tool that works is better than a fully-themed one that breaks on updates.
