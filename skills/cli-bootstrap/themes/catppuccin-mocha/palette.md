# Catppuccin Mocha — Color Reference Card

> Community classic — warm pastel accents, broadest ecosystem support.

## Background Surfaces

| Name     | Hex       | Best for                              |
|----------|-----------|---------------------------------------|
| Void     | `#181825` | Tab bar background, mantle            |
| Ink      | `#181825` | Inactive tab background               |
| Sumi     | `#1E1E2E` | Primary background (base), ANSI black |
| Stone    | `#313244` | Surface0, one elevation up            |
| Pebble   | `#45475A` | Surface1, selection bg                |
| Drift    | `#585B70` | Surface2, borders                     |
| Mist     | `#585B70` | ANSI bright black, dim UI elements    |
| Fog      | `#6C7086` | Overlay0                              |

## Foreground Tones

| Name      | Hex       | Best for                             |
|-----------|-----------|--------------------------------------|
| Ash       | `#6C7086` | Comments, inactive text (overlay0)   |
| Clay      | `#7F849C` | Options/flags, graph labels (overlay1)|
| Parchment | `#9399B2` | Secondary text (overlay2)            |
| Ivory     | `#BAC2DE` | Subtext, ANSI white (subtext0)       |
| Silk      | `#CDD6F4` | Primary foreground (text)            |

## Accent Colors (ANSI Normal)

| Name        | Hex       | ANSI | Best for                        |
|-------------|-----------|------|---------------------------------|
| autumnLeaf  | `#F38BA8` | Red  | Errors, unstaged changes        |
| mossGreen   | `#A6E3A1` | Grn  | Valid commands, diff additions   |
| sandGold    | `#F9E2AF` | Yel  | Warnings, globs                 |
| crystalBlue | `#89B4FA` | Blu  | Cursor, URLs, paths, info       |
| oniViolet   | `#CBA6F7` | Mag  | Keywords, reserved words (mauve)|
| waveAqua    | `#94E2D5` | Cyn  | Strings, quoted arguments (teal)|

## Bright Accents (ANSI Bright)

Catppuccin Mocha uses identical normal/bright values:

| Name         | Hex       | ANSI    | Best for                      |
|--------------|-----------|---------|-------------------------------|
| waveRed      | `#F38BA8` | Brt Red | Bell border, bright errors    |
| springGreen  | `#A6E3A1` | Brt Grn | Diff emphasis, success        |
| carpYellow   | `#F9E2AF` | Brt Yel | Highlighted warnings          |
| springBlue   | `#89B4FA` | Brt Blu | Bright links, highlights      |
| springViolet | `#CBA6F7` | Brt Mag | FZF highlight match           |
| waveAqua2    | `#94E2D5` | Brt Cyn | Bright strings, emphasis      |

## Catppuccin-Specific Colors

| Name      | Hex       | Role                                  |
|-----------|-----------|---------------------------------------|
| Rosewater | `#F5E0DC` | Cursor, warm highlight                |
| Flamingo  | `#F2CDCD` | Secondary warm accent                 |
| Pink      | `#F5C2E7` | Tertiary accent                       |
| Mauve     | `#CBA6F7` | Primary purple (= oniViolet)          |
| Maroon    | `#EBA0AC` | Muted red variant                     |
| Peach     | `#FAB387` | Orange accent                         |
| Teal      | `#94E2D5` | Primary cyan (= waveAqua)             |
| Sky       | `#89DCFE` | Light blue accent                     |
| Sapphire  | `#74C7EC` | Deep blue accent                      |
| Lavender  | `#B4BEFE` | Light purple accent                   |

## Special

| Role             | Hex       | Source color   |
|------------------|-----------|----------------|
| Cursor           | `#F5E0DC` | Rosewater      |
| Cursor trail     | `#CBA6F7` | Mauve          |
| Active border    | `#89B4FA` | Blue           |
| Inactive border  | `#313244` | Surface0       |
| Delta minus bg   | `#302030` | Red into Base  |
| Delta plus bg    | `#203028` | Green into Base|
