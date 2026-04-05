#!/usr/bin/env bash
# Module: Starship — cross-shell prompt
# Dependencies: none
# Configs: starship.toml

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="starship"
MODULE_DESC="Install Starship prompt and symlink Wavefront config"

module_explain() {
    header "Starship — Why this prompt?"

    info "Starship is a cross-shell prompt written in Rust. It's blazing fast"
    info "(single-digit millisecond rendering), works in zsh/bash/fish/nushell,"
    info "and uses a single TOML file for all configuration."
    info ""

    info "Why it matters for Wavefront:"
    info "  • No framework dependency — it doesn't need Oh My Zsh or any plugin manager."
    info "    Your .zshrc stays clean. Starship handles the prompt, period."
    info "  • TOML config — human-readable, version-controllable, easy to tweak."
    info "  • Context-aware — shows git branch, language versions, Docker context,"
    info "    exit codes, and command duration only when relevant."
    info "  • Transient prompt — after running a command, the full prompt collapses"
    info "    to a minimal '>' marker. Keeps scrollback uncluttered."
    info ""

    info "Alternatives considered:"
    info "  • Oh My Zsh themes — huge framework, slow startup, zsh-only."
    info "  • Powerlevel10k — powerful but has a config wizard that generates"
    info "    a ~1000 line .p10k.zsh. Hard to version-control or understand."
    info "  • pure — minimal and elegant, but limited customization."
    info "  Starship wins on speed, simplicity, and cross-shell portability."
}

module_install() {
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            install_pkg starship
            ;;
        *)
            # Official installer works on all Linux distros
            info "Installing Starship via official installer..."
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
    esac
}

module_configure() {
    local source_file="$SCRIPT_DIR/configs/starship.toml"
    local dest_file="$HOME/.config/starship.toml"

    link_config "$source_file" "$dest_file"
    success "Starship config symlinked to $dest_file"
}

module_verify() {
    local ok=0

    if command -v starship &>/dev/null; then
        local ver
        ver="$(starship --version 2>/dev/null | head -1)"
        success "Starship installed: $ver"
    else
        error "Starship binary not found in PATH"
        ok=1
    fi

    if [[ -L "$HOME/.config/starship.toml" || -f "$HOME/.config/starship.toml" ]]; then
        success "Config present: ~/.config/starship.toml"
    else
        warn "Missing config: ~/.config/starship.toml"
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
