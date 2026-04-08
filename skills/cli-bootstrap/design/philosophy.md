# Wavefront: Design Philosophy

## The Aesthetic

Ink on warm paper. Not a neon cave, not a sterile white void.

The terminal should feel like a Japanese woodblock print -- muted warmth, deliberate composition, nothing competing for attention. Every element earns its place; everything else is absence.

## Core Principles

### Ma (間) -- Negative Space

Empty space is not wasted space. It is structure. Generous padding, breathing room between elements, and restrained density create a workspace that feels calm under sustained focus. Line height, margins, and prompt spacing all serve this.

### Stillness Over Motion

No blinking cursors. No animated transitions. No pulsing highlights. The screen changes when you act; otherwise it is still. A woodblock print does not fidget.

### Warmth Without Loudness

The palette sits in warm neutrals with an indigo undertone -- like aged paper under low light. Accents exist but never shout. A red error and a green success should feel equally weighted, not like one is screaming over the other.

### Perceptual Uniformity

Accent colors are tuned in Okhsl color space so that no single hue visually dominates. A red at the same lightness and saturation as a blue should feel the same "volume." This prevents the common problem where terminal reds and yellows overpower blues and cyans.

### Restraint

If a default is good, keep it. If a built-in theme matches the intent, use it rather than hand-rolling hex values. Configuration should express intent, not demonstrate completeness. The goal is a cohesive result, not a maximally customized one.

## What This Is Not

- Not a rice showcase. No transparency for its own sake, no blur, no animated backgrounds.
- Not minimal for ideology. Tools should be rich and capable -- the aesthetic shapes how they present information, not how much they can do.
- Not fragile. The design should degrade gracefully when a font is missing, a terminal lacks true color, or a tool doesn't support theming.
