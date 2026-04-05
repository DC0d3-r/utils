#!/usr/bin/env bash
# Module: Btop — system resource monitor with Wavefront theme
# Dependencies: none
# Configs: btop.conf → ~/.config/btop/btop.conf
#          themes/wavefront.theme → ~/.config/btop/themes/wavefront.theme

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="btop"
MODULE_DESC="Install btop system monitor with Wavefront theme"

module_explain() {
    header "Btop — System monitoring, beautifully"

    info "Btop is a resource monitor that shows CPU, memory, disks, network, and"
    info "processes — all in one terminal window with braille-character graphs."
    info "It's the 'top' replacement you'll actually want to look at."
    info ""

    info "What you get:"
    info "  • CPU: per-core usage with braille sparkline graphs"
    info "  • Memory: RAM + swap with bar charts and breakdown"
    info "  • Disks: I/O rates and usage for all mounted volumes"
    info "  • Network: upload/download graphs with rate display"
    info "  • Processes: sortable, filterable, with tree view — kill with 'k'"
    info ""

    info "The Wavefront theme:"
    info "  Custom .theme file using the Wavefront palette. Main bg is sumiInk"
    info "  (#1F1F28), graphs use crystalBlue and mossGreen, alerts in autumnLeaf."
    info "  The config sets wavefront as the default theme and enables truecolor."
    info ""

    info "Alternatives considered:"
    info "  • htop — simpler, no graphs, no network/disk panels. Fine for servers."
    info "  • glances — Python-based, heavier, web UI mode. Overkill for local use."
    info "  • bottom (btm) — Rust, similar concept but less polished theme support."
    info "  • zenith — Rust, nice but less actively maintained."
    info "  Btop wins on visual quality and theme customization."
}

module_install() {
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            install_pkg btop
            ;;
        ubuntu|debian)
            install_pkg btop
            ;;
        fedora)
            install_pkg btop
            ;;
        arch)
            install_pkg btop
            ;;
        *)
            error "Unsupported OS. Install btop from: https://github.com/aristocratos/btop"
            return 1
            ;;
    esac
}

module_configure() {
    local btop_config_dir="$HOME/.config/btop"
    local btop_theme_dir="$btop_config_dir/themes"

    # Symlink the main config
    link_config "$SCRIPT_DIR/configs/btop/btop.conf" "$btop_config_dir/btop.conf"

    # Symlink the Wavefront theme file
    mkdir -p "$btop_theme_dir"
    link_config "$SCRIPT_DIR/configs/btop/themes/wavefront.theme" "$btop_theme_dir/wavefront.theme"

    success "Btop config and theme symlinked to $btop_config_dir"
}

module_verify() {
    local ok=0

    if command -v btop &>/dev/null; then
        local ver
        ver="$(btop --version 2>/dev/null | head -1)"
        success "Btop installed: $ver"
    else
        error "Btop binary not found in PATH"
        ok=1
    fi

    if [[ -L "$HOME/.config/btop/btop.conf" || -f "$HOME/.config/btop/btop.conf" ]]; then
        success "Config present: ~/.config/btop/btop.conf"
    else
        warn "Missing config: ~/.config/btop/btop.conf"
        ok=1
    fi

    if [[ -L "$HOME/.config/btop/themes/wavefront.theme" || -f "$HOME/.config/btop/themes/wavefront.theme" ]]; then
        success "Theme present: ~/.config/btop/themes/wavefront.theme"
    else
        warn "Missing theme: ~/.config/btop/themes/wavefront.theme"
        ok=1
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
