# Wavefront: Typography

## Requirements

A Nerd Font patched monospace font is required. Tools like eza, starship, and lazygit depend on Nerd Font icons for file type glyphs, git indicators, and UI chrome.

## Recommended Fonts

### Primary: IosevkaTerm Nerd Font

Narrow, dense, geometric. The character proportions echo Japanese typographic sensibility -- compact but never cramped. Good for information-dense layouts.

**Caveat:** Iosevka Regular weight renders thin on Linux with FreeType. Use **Medium** weight or enable font thickening in your terminal to avoid spindly strokes.

### Alternative: Fira Code Nerd Font

Wider, heavier strokes. Renders more consistently across font engines without weight adjustments. A safe default if Iosevka feels too light.

### Italic: MonaspiceRn Nerd Font (Monaspace Radon)

A handwritten-texture italic face. Use for comments and decorative emphasis. The textural contrast against the geometric primary font creates clear visual separation without relying on color alone.

Configure your terminal to use this as the italic font face. Not all terminals support per-style font overrides -- if yours doesn't, the primary font's built-in italic is fine.

## Sizing

Don't prescribe exact font sizes. The right size depends on display DPI, scaling factor, viewing distance, and preference. Start with whatever looks comfortable and adjust.

## Line Height

Add 10-20% extra line height above the default (e.g., 1.1 to 1.2). This is the typographic expression of ma -- breathing room between lines reduces visual density and improves sustained readability.

Don't exceed 1.3. Too much line height breaks the visual connection between related lines and wastes vertical space.

## Ligatures

Enable ligatures for operators and arrows (`=>`, `->`, `!=`, `<=`). They reduce visual noise in code.

Disable ligatures at the cursor position if your terminal supports it (kitty does via `disable_ligatures cursor`). This preserves accurate cursor placement during editing.

## Cell Dimensions

Some terminals allow explicit cell width/height adjustments. Use these sparingly -- they interact with line height and font metrics in non-obvious ways. Prefer adjusting line height alone unless you have a specific reason.
