#!/usr/bin/env bash
# Module: Greeter — terminal artwork displayed on shell startup
# Dependencies: kitty (02)
# Configs: greeter image → ~/.config/wavefront/greeter/enso-koi.jpg

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="greeter"
MODULE_DESC="Set up the terminal greeter — ensō artwork on each new shell"

module_explain() {
    header "Greeter — The ensō and the koi"

    info "Every time you open a new terminal, a piece of artwork appears:"
    info "an ensō (円相) — a Zen circle — with koi fish."
    info ""

    info "The ensō is one of the most sacred symbols in Zen Buddhism."
    info "A single brushstroke, drawn in one breath, representing:"
    info "  • Enlightenment, the void, and the beauty of imperfection"
    info "  • wabi-sabi — nothing is finished, nothing is perfect"
    info "  • The moment of creative flow — mushin (no-mind)"
    info ""

    info "The koi represent perseverance. In Japanese legend, a koi that swims"
    info "upstream through the Dragon Gate waterfall transforms into a dragon."
    info "Every terminal session is a small journey upstream."
    info ""

    info "How it works:"
    info "  The image is displayed using Kitty's image protocol (kitten icat)."
    info "  This only works in Kitty — other terminals silently skip the greeter."
    info "  wavefront.zsh handles the display logic: it checks for KITTY_PID,"
    info "  skips in VS Code and Emacs, and only shows once per session."
    info ""

    info "Optionally, a background noise texture can be generated via ImageMagick"
    info "to add a subtle paper-like grain behind the ensō. This is purely cosmetic"
    info "and only runs if ImageMagick is available."
}

module_install() {
    # The greeter is an image file — no binary to install.
    # Optionally check for ImageMagick for the noise texture generator.
    if command -v magick &>/dev/null || command -v convert &>/dev/null; then
        info "ImageMagick found — noise texture generation available."
    else
        info "ImageMagick not found — noise texture will be skipped (optional)."
        info "Install via: brew install imagemagick (macOS) or apt install imagemagick (Linux)"
    fi
}

module_configure() {
    local source_img="$SCRIPT_DIR/assets/greeter/enso-koi.jpg"
    local dest_dir="$HOME/.config/wavefront/greeter"
    local dest_img="$dest_dir/enso-koi.jpg"

    if [[ ! -f "$source_img" ]]; then
        error "Greeter image not found: $source_img"
        error "Expected enso-koi.jpg in the assets/greeter/ directory."
        return 1
    fi

    # Copy the image (not symlink — it's a binary asset, and symlinking
    # images across filesystems can confuse some tools)
    mkdir -p "$dest_dir"
    copy_config "$source_img" "$dest_img"

    # Generate background noise texture if ImageMagick is available
    _generate_noise_texture "$dest_dir"

    success "Greeter image installed to $dest_img"
    info "The greeter is displayed by wavefront.zsh (guarded for Kitty-only)."
}

_generate_noise_texture() {
    # Creates a subtle noise texture PNG that can be composited behind the ensō.
    # This is a purely optional cosmetic enhancement.
    local dest_dir="$1"
    local noise_file="$dest_dir/noise.png"

    # Check for ImageMagick (v7 = 'magick', v6 = 'convert')
    local magick_cmd=""
    if command -v magick &>/dev/null; then
        magick_cmd="magick"
    elif command -v convert &>/dev/null; then
        magick_cmd="convert"
    fi

    if [[ -z "$magick_cmd" ]]; then
        info "Skipping noise texture — ImageMagick not available."
        return 0
    fi

    # Only generate if it doesn't already exist (it's deterministic enough
    # that regenerating on every run is wasteful)
    if [[ -f "$noise_file" ]]; then
        info "Noise texture already exists — skipping generation."
        return 0
    fi

    info "Generating background noise texture..."
    # Create a small noise pattern: 200x200 plasma noise, muted to near-black.
    # The result is a subtle grain that gives the terminal background texture.
    $magick_cmd -size 200x200 xc: +noise Gaussian \
        -colorspace Gray \
        -brightness-contrast -90x-80 \
        "$noise_file" 2>/dev/null

    if [[ -f "$noise_file" ]]; then
        success "Noise texture generated: $noise_file"
    else
        warn "Noise texture generation failed (non-critical)."
    fi
}

module_verify() {
    local ok=0
    local dest_img="$HOME/.config/wavefront/greeter/enso-koi.jpg"

    if [[ -f "$dest_img" ]]; then
        success "Greeter image present: $dest_img"
    else
        error "Greeter image missing: $dest_img"
        ok=1
    fi

    # Check that Kitty is available (greeter only works in Kitty)
    if command -v kitty &>/dev/null; then
        success "Kitty available — greeter will display on startup"
    else
        warn "Kitty not installed — greeter requires Kitty's image protocol"
        # Not a hard failure — the greeter gracefully degrades (wavefront.zsh
        # checks for KITTY_PID before attempting icat)
    fi

    # Check kitten icat is available
    if command -v kitten &>/dev/null; then
        success "kitten command available (for icat image display)"
    else
        info "kitten not in PATH — will work if Kitty is installed"
    fi

    return $ok
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    module_explain
    ask "Install $MODULE_NAME?" "y" && module_install
    module_configure
    module_verify
fi
