# Rose Pine — Color Reference Card

> Community classic — soho vibes, muted pastels with romantic warmth.

## Background Surfaces

| Name     | Hex       | Best for                              |
|----------|-----------|---------------------------------------|
| Void     | `#191724` | Primary background (base)             |
| Ink      | `#1F1D2E` | Tab bar, surface layer                |
| Sumi     | `#191724` | ANSI black, base                      |
| Stone    | `#26233A` | Selection bg, overlay                 |
| Pebble   | `#312F44` | Selected range, deeper overlay        |
| Drift    | `#403D52` | Borders, ANSI bright black            |
| Mist     | `#403D52` | Dim UI elements                       |
| Fog      | `#555169` | Subtle separators                     |

## Foreground Tones

| Name      | Hex       | Best for                             |
|-----------|-----------|--------------------------------------|
| Ash       | `#555169` | Comments, inactive text              |
| Clay      | `#6E6A86` | Options/flags, graph labels (muted)  |
| Parchment | `#908CAA` | Secondary text (subtle)              |
| Ivory     | `#E0DEF4` | Primary foreground, ANSI white       |
| Silk      | `#E0DEF4` | Selection fg, emphasis (= ivory)     |

## Accent Colors (ANSI Normal)

| Name        | Hex       | ANSI | Best for                        |
|-------------|-----------|------|---------------------------------|
| autumnLeaf  | `#EB6F92` | Red  | Errors, unstaged changes (love) |
| mossGreen   | `#31748F` | Grn  | Valid commands, additions (pine) |
| sandGold    | `#F6C177` | Yel  | Warnings, globs (gold)          |
| crystalBlue | `#9CCFD8` | Blu  | Cursor, URLs, paths (foam)      |
| oniViolet   | `#C4A7E7` | Mag  | Keywords, reserved words (iris)  |
| waveAqua    | `#EBBCBA` | Cyn  | Strings, quoted arguments (rose) |

## Bright Accents (ANSI Bright)

Rose Pine uses identical normal/bright values:

| Name         | Hex       | ANSI    | Best for                      |
|--------------|-----------|---------|-------------------------------|
| waveRed      | `#EB6F92` | Brt Red | Bell border, bright errors    |
| springGreen  | `#31748F` | Brt Grn | Diff emphasis, success        |
| carpYellow   | `#F6C177` | Brt Yel | Highlighted warnings          |
| springBlue   | `#9CCFD8` | Brt Blu | Bright links, highlights      |
| springViolet | `#C4A7E7` | Brt Mag | FZF highlight match           |
| waveAqua2    | `#EBBCBA` | Brt Cyn | Bright strings, emphasis      |

## Rose Pine-Specific Colors

| Name    | Hex       | Role                                    |
|---------|-----------|---------------------------------------- |
| Love    | `#EB6F92` | Diagnostic errors, builtins             |
| Gold    | `#F6C177` | Warnings, parameters                    |
| Rose    | `#EBBCBA` | Strings, tags                           |
| Pine    | `#31748F` | Functions, conditionals                 |
| Foam    | `#9CCFD8` | Builtins, types, URIs                   |
| Iris    | `#C4A7E7` | Keywords, identifiers                   |
| Subtle  | `#908CAA` | Comments, secondary content             |
| Muted   | `#6E6A86` | Ignored, disabled content               |

## Special

| Role             | Hex       | Source color   |
|------------------|-----------|----------------|
| Cursor           | `#E0DEF4` | Text           |
| Cursor trail     | `#C4A7E7` | Iris           |
| Active border    | `#C4A7E7` | Iris           |
| Inactive border  | `#26233A` | Overlay        |
| Delta minus bg   | `#271B24` | Love into Base |
| Delta plus bg    | `#1B2430` | Pine into Base |
