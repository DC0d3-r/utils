#!/usr/bin/env bash
# Module: Git Delta — syntax-highlighted side-by-side diffs
# Dependencies: none
# Configs: delta.gitconfig → ~/.config/wavefront/delta.gitconfig

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="git-delta"
MODULE_DESC="Install delta for beautiful git diffs with syntax highlighting"

module_explain() {
    header "Git Delta — Why pretty diffs matter"

    info "Delta replaces git's default diff output with syntax-highlighted,"
    info "side-by-side diffs that include line numbers and hunk navigation."
    info ""

    info "What you get:"
    info "  • Every 'git diff', 'git log -p', and 'git show' becomes readable."
    info "  • Side-by-side view — old on the left, new on the right."
    info "  • Line numbers in the gutter, just like your editor."
    info "  • Syntax highlighting in the diff — you can read the actual code,"
    info "    not just red/green lines."
    info "  • n/N navigation to jump between hunks (via less keybindings)."
    info ""

    info "How it works:"
    info "  Delta is configured as git's 'pager' — it intercepts all git output"
    info "  that goes through a pager and reformats it. No workflow change needed."
    info "  We include a delta.gitconfig that your .gitconfig includes."
    info ""

    info "Alternatives considered:"
    info "  • diff-so-fancy — nicer than default, but no syntax highlighting."
    info "  • difftastic — structural/AST-aware diffs. Very cool, but a different"
    info "    paradigm — it reflows code, which can be confusing for reviews."
    info "  Delta is the sweet spot: familiar patch format, dramatically improved readability."
}

module_install() {
    # Delta's package name varies by platform
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            install_pkg git-delta
            ;;
        ubuntu|debian)
            # Delta isn't in default apt repos — install from GitHub releases
            if command -v delta &>/dev/null; then
                info "Delta already installed"
                return 0
            fi
            info "Installing delta from GitHub releases..."
            local arch
            arch="$(dpkg --print-architecture)"
            local latest
            latest="$(curl -sS https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+' || echo '0.18.2')"
            local deb_url="https://github.com/dandavison/delta/releases/download/${latest}/git-delta_${latest}_${arch}.deb"
            local tmp_deb="/tmp/git-delta.deb"
            curl -fsSL "$deb_url" -o "$tmp_deb"
            sudo dpkg -i "$tmp_deb"
            rm -f "$tmp_deb"
            ;;
        fedora)
            install_pkg git-delta
            ;;
        arch)
            install_pkg git-delta
            ;;
        *)
            error "Unsupported OS. Install delta from: https://github.com/dandavison/delta"
            return 1
            ;;
    esac
}

module_configure() {
    local source_file="$SCRIPT_DIR/configs/git/delta.gitconfig"
    local dest_file="$HOME/.config/wavefront/delta.gitconfig"
    local gitconfig="$HOME/.gitconfig"

    # Copy delta config to the wavefront config directory
    copy_config "$source_file" "$dest_file"

    # Add [include] to .gitconfig if not already present.
    # We check for the exact path to avoid duplicates.
    local include_path="~/.config/wavefront/delta.gitconfig"
    if [[ -f "$gitconfig" ]] && grep -qF "$include_path" "$gitconfig"; then
        info "Include line already present in $gitconfig — skipping."
    else
        # Append the include directive
        {
            echo ""
            echo "# Wavefront — delta (syntax-highlighted diffs)"
            echo "[include]"
            echo "    path = $include_path"
        } >> "$gitconfig"
        success "Added delta include to $gitconfig"
    fi
}

module_verify() {
    local ok=0

    if command -v delta &>/dev/null; then
        local ver
        ver="$(delta --version 2>/dev/null | head -1)"
        success "Delta installed: $ver"
    else
        error "Delta binary not found in PATH"
        ok=1
    fi

    # Check delta.gitconfig exists
    if [[ -f "$HOME/.config/wavefront/delta.gitconfig" ]]; then
        success "Config present: ~/.config/wavefront/delta.gitconfig"
    else
        warn "Missing config: ~/.config/wavefront/delta.gitconfig"
        ok=1
    fi

    # Check git is using delta as its pager
    local pager
    pager="$(git config --get core.pager 2>/dev/null || echo '')"
    if [[ "$pager" == "delta" ]]; then
        success "Git pager is set to delta"
    else
        warn "Git pager is '$pager' (expected 'delta'). Include may not be loaded yet."
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
