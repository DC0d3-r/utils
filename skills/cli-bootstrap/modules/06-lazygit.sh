#!/usr/bin/env bash
# Module: Lazygit — terminal UI for git
# Dependencies: none
# Configs: lazygit/config.yml → ~/.config/lazygit/config.yml

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="lazygit"
MODULE_DESC="Install lazygit TUI and symlink Wavefront-themed config"

module_explain() {
    header "Lazygit — Git without memorizing commands"

    info "Lazygit is a terminal UI for git. Instead of remembering arcane flags"
    info "like 'git rebase -i HEAD~3' or 'git stash push -m \"wip\"', you get"
    info "a visual interface where you can:"
    info ""
    info "  • Stage individual hunks or lines (not just whole files)"
    info "  • Interactive rebase by dragging commits up/down"
    info "  • Resolve merge conflicts side-by-side"
    info "  • Cherry-pick, squash, amend — all with single keypresses"
    info "  • See branches, stashes, and reflog in one view"
    info ""

    info "The Wavefront theme:"
    info "  The config uses sandGold (#C4B28A) for active borders, matching Kitty's"
    info "  active window border. Selected lines use the Stone elevation (#2A2A37)."
    info "  The entire color hierarchy follows Wavefront's palette — crystalBlue"
    info "  for hints, autumnLeaf for unstaged changes, mossGreen for staged."
    info ""

    info "Alternatives considered:"
    info "  • tig — excellent for reading history, but mostly read-only."
    info "  • gitui — Rust, fast, but fewer features (no interactive rebase)."
    info "  • magit — the gold standard, but requires Emacs."
    info "  Lazygit wins for terminal users: full git workflow, no editor dependency."
}

module_install() {
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            install_pkg lazygit
            ;;
        ubuntu|debian)
            # Lazygit isn't in default apt repos — install from GitHub releases
            if command -v lazygit &>/dev/null; then
                info "Lazygit already installed"
                return 0
            fi
            info "Installing lazygit from GitHub releases..."
            local version
            version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
                | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/' || echo '0.44.1')"
            local arch
            arch="$(uname -m)"
            case "$arch" in
                x86_64)  arch="x86_64" ;;
                aarch64) arch="arm64"  ;;
            esac
            local tmp="/tmp/lazygit.tar.gz"
            curl -fsSL -o "$tmp" \
                "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz"
            sudo tar -xzf "$tmp" -C /usr/local/bin lazygit
            rm -f "$tmp"
            ;;
        fedora)
            # Fedora has lazygit in COPR or official repos depending on version
            sudo dnf copr enable atim/lazygit -y 2>/dev/null || true
            install_pkg lazygit
            ;;
        arch)
            install_pkg lazygit
            ;;
        *)
            error "Unsupported OS. Install lazygit from: https://github.com/jesseduffield/lazygit"
            return 1
            ;;
    esac
}

module_configure() {
    local source_file="$SCRIPT_DIR/configs/lazygit/config.yml"
    local dest_file="$HOME/.config/lazygit/config.yml"

    link_config "$source_file" "$dest_file"
    success "Lazygit config symlinked to $dest_file"
}

module_verify() {
    local ok=0

    if command -v lazygit &>/dev/null; then
        local ver
        ver="$(lazygit --version 2>/dev/null | head -1)"
        success "Lazygit installed: $ver"
    else
        error "Lazygit binary not found in PATH"
        ok=1
    fi

    if [[ -L "$HOME/.config/lazygit/config.yml" || -f "$HOME/.config/lazygit/config.yml" ]]; then
        success "Config present: ~/.config/lazygit/config.yml"
    else
        warn "Missing config: ~/.config/lazygit/config.yml"
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
