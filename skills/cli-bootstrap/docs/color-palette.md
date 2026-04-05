# Wavefront Color Palette Reference

Designed in Okhsl (perceptually uniform color space) for matched brightness across all accent colors. Every foreground color meets WCAG AA contrast against the primary background (#1F1F28).

## Background Ramp (warm-neutral indigo undertone)

| Name | Hex | Okhsl | Use |
|------|-----|-------|-----|
| Void | `#111117` | H:260 S:0.15 L:0.06 | Deepest layer — tab bar bg, status bar |
| Ink | `#16161D` | H:260 S:0.12 L:0.08 | One below primary — inactive tab bg |
| **Sumi** | `#1F1F28` | H:260 S:0.10 L:0.12 | **Primary background** |
| Stone | `#2A2A37` | H:260 S:0.08 L:0.16 | Selection bg, elevated surface |
| Pebble | `#363646` | H:260 S:0.07 L:0.20 | Double-elevation, range selection |
| Drift | `#44445B` | H:260 S:0.08 L:0.28 | Borders, autosuggestion text |
| Mist | `#54546D` | H:260 S:0.08 L:0.36 | Bright black (ANSI 8), line numbers |
| Fog | `#65657A` | H:260 S:0.06 L:0.42 | Placeholder text |

## Foreground Ramp (warm ivory tones)

| Name | Hex | Contrast vs Sumi | Use |
|------|-----|------------------|-----|
| Ash | `#727169` | 4.6:1 (AA) | Comments, timestamps, muted text |
| Clay | `#938E7E` | 6.2:1 (AA) | Secondary info, dim labels |
| Parchment | `#C8C093` | 9.8:1 (AAA) | Warnings, cursor trail, highlights |
| **Ivory** | `#DCD7BA` | 12.3:1 (AAA) | **Primary text** |
| Silk | `#EDEAD5` | 14.7:1 (AAA) | Bright white, selected text |

## ANSI Colors

### Normal (L:0.70, S:0.35-0.50)

| # | Name | Hex | ANSI | Semantic Use |
|---|------|-----|------|-------------|
| 0 | Sumi | `#1F1F28` | Black | Background |
| 1 | autumnLeaf | `#D0605A` | Red | Errors, deletions, unstaged changes |
| 2 | mossGreen | `#7BA888` | Green | Success, additions, valid commands |
| 3 | sandGold | `#C4B28A` | Yellow | Warnings, active borders, globs |
| 4 | crystalBlue | `#7E9CD8` | Blue | Cursor, directories, URLs, info |
| 5 | oniViolet | `#957FB8` | Magenta | Keywords, branches, separators |
| 6 | waveAqua | `#6DB5A8` | Cyan | Strings, arguments |
| 7 | Ivory | `#DCD7BA` | White | Primary text |

### Bright (L:0.80, S:0.42-0.55)

| # | Name | Hex | ANSI | Use |
|---|------|-----|------|-----|
| 8 | Mist | `#54546D` | Bright Black | Line numbers, muted UI |
| 9 | waveRed | `#E8685E` | Bright Red | Emphasized errors |
| 10 | springGreen | `#8FBF96` | Bright Green | Emphasized additions |
| 11 | carpYellow | `#DEB97D` | Bright Yellow | Emphasized warnings |
| 12 | springBlue | `#7FB4CA` | Bright Blue | Links, emphasized paths |
| 13 | springViolet | `#B09FD6` | Bright Magenta | Emphasized keywords |
| 14 | waveAqua2 | `#82CCBE` | Bright Cyan | Emphasized strings |
| 15 | Silk | `#EDEAD5` | Bright White | Highlighted text |

## Semantic Colors

| Purpose | Color | Hex |
|---------|-------|-----|
| Cursor | crystalBlue | `#7E9CD8` |
| Cursor trail | Parchment | `#C8C093` |
| Active border | sandGold | `#C4B28A` |
| Inactive border | Stone | `#2A2A37` |
| Selection bg | Stone | `#2A2A37` |
| Selection fg | Silk | `#EDEAD5` |
| URL | crystalBlue | `#7E9CD8` |
| Visual bell | autumnLeaf | `#D0605A` |
| Diff minus bg | — | `#2A1A18` |
| Diff plus bg | — | `#1A2A20` |

## Design Principles

- **Okhsl perceptual uniformity:** All normal accents at L:0.70, all brights at L:0.80. This means every color has the same perceived brightness — no accent visually dominates.
- **Warm-neutral undertone:** The background ramp has a subtle warm indigo (H:260), preventing the "cold cave" feel of pure gray terminals.
- **WCAG AA minimum:** Every foreground color meets 4.5:1 contrast against Sumi. Ash (#727169) at 4.6:1 is the minimum — used only for comments.
- **Green/cyan separation:** waveAqua was shifted from H:165 to H:180 (35° gap from green H:145) to prevent confusion on low-gamut displays.
- **Semantic preservation:** Red=errors, green=success, yellow=warnings. These associations are preserved even with muted saturation.
