#!/usr/bin/env bash
# Module: CLI Tools — modern replacements for cat, ls, find, grep, history, cd
# Dependencies: none
# Configs: none (colors/aliases come from wavefront.zsh)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="cli-tools"
MODULE_DESC="Install modern CLI tools: bat, eza, fd, ripgrep, fzf, zoxide"

module_explain() {
    header "CLI Tools — The modern Unix toolkit"

    info "These six tools replace standard Unix commands with faster, friendlier"
    info "versions. They're all standalone binaries — no frameworks, no daemons."
    info "wavefront.zsh aliases the old names to the new ones, so your muscle"
    info "memory keeps working."
    info ""

    info "bat (replaces cat)"
    info "  Syntax highlighting for 200+ languages, line numbers, git gutter marks."
    info "  When you 'cat' a file, you actually see the code — not a wall of text."
    info "  Also powers fzf's preview window."
    info ""

    info "eza (replaces ls)"
    info "  File listings with icons (Nerd Font glyphs), git status per file,"
    info "  tree view built-in, and human-readable sizes by default."
    info "  'ls' becomes beautiful. 'lt' gives you a tree."
    info ""

    info "fd (replaces find)"
    info "  Intuitive syntax: 'fd pattern' instead of 'find . -name \"*pattern*\"'."
    info "  Ignores .gitignore by default. 5-10x faster than find on large trees."
    info ""

    info "ripgrep / rg (replaces grep)"
    info "  Fastest code search tool available. Respects .gitignore, searches"
    info "  recursively by default, shows color-coded results with context."
    info "  This is what powers VS Code's search and Claude Code's Grep tool."
    info ""

    info "fzf (fuzzy finder)"
    info "  Turns any list into a searchable, filterable menu. Powers:"
    info "  • Ctrl-R — fuzzy search through shell history"
    info "  • Ctrl-T — fuzzy file picker"
    info "  • Alt-C — fuzzy directory jump"
    info "  • piped input — 'git branch | fzf' to pick a branch"
    info "  The Wavefront theme colors its UI to match the terminal palette."
    info ""

    info "zoxide (replaces cd)"
    info "  A smarter 'cd' that learns your habits. After visiting a directory once,"
    info "  you can jump back with just a fragment: 'z home' → ~/code/homelab."
    info "  Uses frecency (frequency + recency) to rank matches."
}

module_install() {
    local os
    os="$(detect_os)"

    # Tools and their package names across managers
    # Format: binary_name:brew:apt:dnf:pacman
    local -a tools=(
        "bat:bat:bat:bat:bat"
        "eza:eza:eza:eza:eza"
        "fd:fd:fd-find:fd-find:fd"
        "rg:ripgrep:ripgrep:ripgrep:ripgrep"
        "fzf:fzf:fzf:fzf:fzf"
        "zoxide:zoxide:zoxide:zoxide:zoxide"
    )

    for entry in "${tools[@]}"; do
        IFS=':' read -r bin brew apt dnf pacman <<< "$entry"

        # Skip if already installed
        if command -v "$bin" &>/dev/null; then
            info "$bin already installed — skipping"
            continue
        fi

        case "$os" in
            macos)         install_pkg "$brew" ;;
            ubuntu|debian) install_pkg "$apt" "$apt" "$apt" ;;
            fedora)        install_pkg "$dnf" "$dnf" "$dnf" "$dnf" ;;
            arch)          install_pkg "$pacman" "$pacman" "$pacman" "$pacman" "$pacman" ;;
            *)             warn "Cannot install $bin — unsupported OS" ;;
        esac
    done

    # On Debian/Ubuntu, fd-find installs as 'fdfind'. Create a symlink so
    # scripts and aliases that expect 'fd' work correctly.
    if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
        if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
            local bin_dir="$HOME/.local/bin"
            mkdir -p "$bin_dir"
            ln -sf "$(which fdfind)" "$bin_dir/fd"
            info "Created fd → fdfind symlink in $bin_dir"
        fi
    fi
}

module_configure() {
    # No config files to symlink — all colors, aliases, and FZF theme
    # are set in wavefront.zsh (handled by 04-zsh.sh).
    info "No config files to install. Colors and aliases come from wavefront.zsh."
    info "Tools configured: BAT_THEME, FZF_DEFAULT_OPTS, eza aliases, zoxide init."
}

module_verify() {
    local ok=0
    local -a expected_cmds=(bat eza fzf rg zoxide)

    for cmd in "${expected_cmds[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            success "$cmd found: $(command -v "$cmd")"
        else
            warn "$cmd not found in PATH"
            ok=1
        fi
    done

    # fd has special handling — might be 'fdfind' on Debian
    if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
        success "fd found: $(command -v fd 2>/dev/null || command -v fdfind)"
    else
        warn "fd (or fdfind) not found in PATH"
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
