# Theme Gallery

Six pre-built color themes, each providing coordinated configs for all tools.

## Switching Themes

```bash
./setup.sh --theme <name>    # Apply a theme
./setup.sh --themes          # List available themes
```

---

## Wavefront (Default)

**Vibe:** Japanese woodblock print — warm-neutral indigo base, muted painterly accents
**Best for:** Daily driving, long coding sessions, focus work
**Designed in:** Okhsl perceptual color space, WCAG AA verified

```
  Background   ████ #1F1F28  (sumi — warm-neutral indigo)
  Foreground   ████ #DCD7BA  (ivory — warm off-white)
  Red          ████ #D0605A  (autumnLeaf)
  Green        ████ #7BA888  (mossGreen)
  Yellow       ████ #C4B28A  (sandGold)
  Blue         ████ #7E9CD8  (crystalBlue)
  Magenta      ████ #957FB8  (oniViolet)
  Cyan         ████ #6DB5A8  (waveAqua)
```

**Character:** Calm, considered. Like coding in a Kyoto garden at dusk. Every color has a natural-material name. Saturation is deliberately low (S:0.35-0.50) so no accent shouts over another.

---

## Neon Depths

**Vibe:** Refined cyberpunk — deep purple void, high-saturation neon accents
**Best for:** Incident response, operational dashboards, late-night debugging
**Origin:** Research candidate A, tied with Wavefront in persona evaluation (207/280)

```
  Background   ████ #181824  (deep void)
  Foreground   ████ #D0CBE4  (cool lavender)
  Red          ████ #FF6B6B  (neon coral)
  Green        ████ #50FA7B  (neon mint)
  Yellow       ████ #F1FA8C  (neon lemon)
  Blue         ████ #6C99FF  (electric blue)
  Magenta      ████ #BD93F9  (neon violet)
  Cyan         ████ #8BE9FD  (neon ice)
```

**Character:** High-energy, tactical. Errors SCREAM. Perfect for scanning logs at 3am. The saturation is intentionally high (S:0.60-0.65) — this is a "christmas tree" theme, but a refined one.

**Why it lost to Wavefront for daily use:** The high saturation causes eye strain after 4-6 hours. But for shorter, high-alertness sessions, it's superior.

---

## Glassmind

**Vibe:** Translucent minimalism — gray-violet monochromatic base, context-aware accents
**Best for:** Screenshots, presentations, aesthetic appeal
**Origin:** Research candidate C (189/280 in persona eval)

```
  Background   ████ #1A1A22  (cool gray)
  Foreground   ████ #D8D4EA  (soft lavender)
  Red          ████ #E07070  (muted coral)
  Green        ████ #70C090  (sage)
  Yellow       ████ #D0B878  (warm gold)
  Blue         █��██ #7090D0  (steel blue)
  Magenta      ████ #A080C0  (dusty violet)
  Cyan         ████ #70B8B0  (muted teal)
```

**Character:** Ethereal, clean. Colors are desaturated enough to look elegant but distinct enough to be functional. Pairs beautifully with dark wallpapers at reduced opacity.

**Why it lost:** The monochromatic ANSI normals blur together in dense terminal output. Works better for coding (syntax highlighting) than ops (log scanning).

---

## Tokyo Night

**Vibe:** Cool blue-purple — the community's darling
**Best for:** Familiarity, wide plugin ecosystem, consistency with Neovim/VSCode themes
**Origin:** Community theme with 500+ ports

```
  Background   ████ #1A1B26  (night blue)
  Foreground   ████ #A9B1D6  (cool gray-blue)
  Red          ████ #F7768E  (sakura pink)
  Green        ████ #9ECE6A  (spring green)
  Yellow       ████ #E0AF68  (warm amber)
  Blue         ████ #7AA2F7  (sky blue)
  Magenta      ████ #BB9AF7  (wisteria)
  Cyan         ████ #7DCFFF  (ice blue)
  Bonus        ████ #73DACA  (teal — bright green)
```

**Character:** Professional, polished. The most "normal" choice. If you use Tokyo Night in your editor, this keeps your terminal consistent.

---

## Catppuccin Mocha

**Vibe:** Warm pastels — soothing, cozy, broadest ecosystem
**Best for:** Maximum consistency (400+ app ports), comfortable extended use
**Origin:** Community theme, largest ecosystem of any terminal color scheme

```
  Background   ████ #1E1E2E  (crust)
  Foreground   ████ #CDD6F4  (text)
  Red          ████ #F38BA8  (red/maroon blend)
  Green        ████ #A6E3A1  (soft green)
  Yellow       ████ #F9E2AF  (warm cream)
  Blue         ████ #89B4FA  (soft blue)
  Magenta      ████ #CBA6F7  (mauve)
  Cyan         ████ #94E2D5  (teal)
  Bonus        ████ #F5E0DC  (rosewater — cursor)
```

**Character:** Warm, inviting, consistent. Every app you use probably has a Catppuccin port. The pastels are designed for comfort — no harsh contrasts.

---

## Rose Pine

**Vibe:** Soho apartment at dusk — muted, elegant, intentional
**Best for:** Elegance, soft on the eyes, 3 variants (main/moon/dawn)
**Origin:** Community theme, known for intentional color restraint

```
  Background   ████ #191724  (base)
  Foreground   ████ #E0DEF4  (text)
  Red          ████ #EB6F92  (love)
  Green        ████ #31748F  (pine — note: this is teal, not green)
  Yellow       ████ #F6C177  (gold)
  Blue         ████ #9CCFD8  (foam)
  Magenta      ████ #C4A7E7  (iris)
  Cyan         ████ #EBBCBA  (rose — note: warm, not cool)
```

**Character:** Opinionated. Rose Pine redefines ANSI green as teal and cyan as warm rose. This breaks convention but creates a uniquely cohesive palette. If you can accept the unconventional mapping, it's one of the most beautiful themes available.

**Note:** Rose Pine's green (#31748F) is actually teal/pine-colored. If you need traditional green = green, this may confuse you in git diffs.

---

## Choosing a Theme

| If you... | Try |
|-----------|-----|
| Code 8+ hours and need zero eye strain | **Wavefront** or **Catppuccin Mocha** |
| Do a lot of ops/incident work | **Neon Depths** |
| Want your screenshots to look amazing | **Glassmind** |
| Already use Tokyo Night in your editor | **Tokyo Night** |
| Want the same theme in every app you own | **Catppuccin Mocha** |
| Want something uniquely beautiful | **Rose Pine** |

All themes can be switched instantly with `./setup.sh --theme <name>`.
