#!/usr/bin/env bash
# Module: Kitty — GPU-accelerated terminal emulator
# Dependencies: fonts (01)
# Configs: kitty.conf, tab_bar.py, toggle_opacity.py

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="kitty"
MODULE_DESC="Install Kitty terminal and symlink Wavefront config + kittens"

module_explain() {
    header "Kitty — Why this terminal?"

    info "Kitty is a GPU-accelerated terminal emulator written in C and Python."
    info "The GPU rendering means smooth scrolling and zero lag even with complex"
    info "prompts, large logs, or image output. It's cross-platform (macOS + Linux)."
    info ""

    info "What makes Kitty special for Wavefront:"
    info "  • Image protocol — 'kitten icat' displays images inline in the terminal."
    info "    This powers the ensō greeter and makes tools like ranger show previews."
    info "  • Python-scriptable — the tab bar and opacity toggle are Python 'kittens'."
    info "  • Built-in splits/tabs — no need for tmux in most workflows."
    info "  • Cursor trails — subtle afterglow effect as the cursor moves."
    info "  • Per-font style overrides — we use IosevkaTerm for regular text and"
    info "    MonaspiceRn (Monaspace Radon) for italic, giving comments a handwritten feel."
    info ""

    info "Alternatives considered:"
    info "  • iTerm2 — macOS only, no Linux. Can't share config across machines."
    info "  • Alacritty — fast, but no tabs, no images, no scripting. Too minimal."
    info "  • WezTerm — Lua config is powerful but verbose. Smaller community."
    info "  • Ghostty — promising (Zig, very fast), but newer and less battle-tested."
    info "  Kitty hits the sweet spot: fast, configurable, cross-platform, mature."
}

module_install() {
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            install_pkg kitty
            ;;
        ubuntu|debian)
            # Official Kitty installer works on all Linux distros
            info "Installing Kitty via official installer..."
            curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
            # Add to PATH via symlink if not already there
            local bin_dir="$HOME/.local/bin"
            mkdir -p "$bin_dir"
            ln -sf "$HOME/.local/kitty.app/bin/kitty" "$bin_dir/kitty"
            ln -sf "$HOME/.local/kitty.app/bin/kitten" "$bin_dir/kitten"
            success "Kitty installed. Make sure $bin_dir is in your PATH."
            ;;
        fedora)
            install_pkg kitty
            ;;
        arch)
            install_pkg kitty
            ;;
        *)
            error "Unsupported OS. Install Kitty from: https://sw.kovidgoyal.net/kitty/"
            return 1
            ;;
    esac
}

module_configure() {
    local kitty_config_dir="$HOME/.config/kitty"
    local configs="$SCRIPT_DIR/configs/kitty"

    # Symlink each config file individually — this lets users add their own
    # overrides without us clobbering the entire directory
    link_config "$configs/kitty.conf"        "$kitty_config_dir/kitty.conf"
    link_config "$configs/tab_bar.py"        "$kitty_config_dir/tab_bar.py"
    link_config "$configs/toggle_opacity.py" "$kitty_config_dir/toggle_opacity.py"

    success "Kitty config symlinked to $kitty_config_dir"
}

module_verify() {
    local ok=0

    # Check binary exists
    if command -v kitty &>/dev/null; then
        local ver
        ver="$(kitty --version 2>/dev/null | head -1)"
        success "Kitty installed: $ver"
    else
        error "Kitty binary not found in PATH"
        ok=1
    fi

    # Check config files are in place
    local kitty_config_dir="$HOME/.config/kitty"
    for f in kitty.conf tab_bar.py toggle_opacity.py; do
        if [[ -L "$kitty_config_dir/$f" || -f "$kitty_config_dir/$f" ]]; then
            success "Config present: $kitty_config_dir/$f"
        else
            warn "Missing config: $kitty_config_dir/$f"
            ok=1
        fi
    done

    return $ok
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    module_explain
    ask "Install $MODULE_NAME?" "y" && module_install
    module_configure
    module_verify
fi
