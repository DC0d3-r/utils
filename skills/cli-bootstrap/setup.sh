#!/usr/bin/env bash
# ==============================================================================
#  CLI Bootstrap — Wavefront Terminal Experience
#  A guided setup for a complete, beautiful CLI environment.
#
#  Usage:
#    ./setup.sh                     # Interactive walkthrough (default)
#    ./setup.sh --all --yes         # Install everything, no prompts
#    ./setup.sh --module fonts      # Run specific module only
#    ./setup.sh --module fonts,kitty # Multiple modules
#    ./setup.sh --theme rose-pine   # Switch to a different theme
#    ./setup.sh --themes            # List available themes
#    ./setup.sh --list              # List available modules
#    ./setup.sh --verify            # Run verification checks only
#    ./setup.sh --dry-run           # Show what would happen
#    ./setup.sh --restore <ts>      # Restore from backup timestamp
# ==============================================================================

set -euo pipefail

# ─── Resolve paths ───────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

# ─── Globals ─────────────────────────────────────────────────────────────────
export YES_MODE=false
export DRY_RUN=false
SELECTED_MODULES=()
ACTION="interactive"  # interactive | modules | all | list | themes | theme | verify | restore

# ─── Module registry (order matters — dependencies first) ───────────────────
# Format: "number:name:description:dependencies"
MODULES=(
    "01:fonts:Nerd Fonts — IosevkaTerm + Monaspace Radon:none"
    "02:kitty:Kitty terminal — GPU-accelerated with image support:fonts"
    "03:starship:Starship prompt — fast, cross-shell, TOML config:none"
    "04:zsh:Zsh config — plugins, aliases, functions, theme colors:starship,cli-tools"
    "05:git-delta:Delta — beautiful side-by-side git diffs:none"
    "06:lazygit:Lazygit — TUI for git operations:none"
    "07:btop:Btop — system monitor with braille graphs:none"
    "08:cli-tools:Modern CLI — bat, eza, fd, ripgrep, fzf, zoxide:none"
    "09:greeter:Terminal greeter — ensō koi artwork on startup:kitty"
)

# ─── Parse arguments ────────────────────────────────────────────────────────
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                ACTION="all"
                shift
                ;;
            --yes|-y)
                YES_MODE=true
                shift
                ;;
            --module)
                ACTION="modules"
                # Split comma-separated list
                IFS=',' read -ra SELECTED_MODULES <<< "$2"
                shift 2
                ;;
            --list)
                ACTION="list"
                shift
                ;;
            --themes)
                ACTION="themes"
                shift
                ;;
            --theme)
                ACTION="theme"
                THEME_NAME="$2"
                shift 2
                ;;
            --verify)
                ACTION="verify"
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --restore)
                ACTION="restore"
                RESTORE_TS="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# ─── Help ────────────────────────────────────────────────────────────────────
show_help() {
    cat <<'EOF'
CLI Bootstrap — Wavefront Terminal Experience

Usage:
  ./setup.sh                        Interactive guided walkthrough
  ./setup.sh --all [--yes]          Install everything (--yes skips prompts)
  ./setup.sh --module <name,...>    Run specific module(s)
  ./setup.sh --theme <name>         Switch color theme
  ./setup.sh --themes               List available themes
  ./setup.sh --list                 List available modules
  ./setup.sh --verify               Run post-install verification
  ./setup.sh --dry-run              Preview actions without changing anything
  ./setup.sh --restore <timestamp>  Restore configs from backup

Modules:
  fonts, kitty, starship, zsh, git-delta, lazygit, btop, cli-tools, greeter

Themes:
  wavefront (default), neon-depths, glassmind, tokyo-night,
  catppuccin-mocha, rose-pine
EOF
}

# ─── Banner ──────────────────────────────────────────────────────────────────
show_banner() {
    local blue="\033[38;2;126;156;216m"
    local gold="\033[38;2;196;178;138m"
    local ivory="\033[38;2;220;215;186m"
    local reset="\033[0m"

    echo ""
    echo -e "${blue}  ╔══════════════════════════════════════════╗${reset}"
    echo -e "${blue}  ║${gold}    CLI Bootstrap — Wavefront v${WAVEFRONT_VERSION}       ${blue}║${reset}"
    echo -e "${blue}  ║${ivory}    Japanese-inspired terminal elegance    ${blue}║${reset}"
    echo -e "${blue}  ╚══════════════════════════════════════════╝${reset}"
    echo ""
}

# ─── List modules ────────────────────────────────────────────────────────────
list_modules() {
    header "Available Modules"
    echo ""
    for entry in "${MODULES[@]}"; do
        IFS=':' read -r num name desc deps <<< "$entry"
        local dep_info=""
        [[ "$deps" != "none" ]] && dep_info=" (needs: $deps)"
        printf "  %s  %-12s %s%s\n" "$num" "$name" "$desc" "$dep_info"
    done
    echo ""
}

# ─── List themes ─────────────────────────────────────────────────────────────
list_themes() {
    header "Available Themes"
    echo ""

    local theme_dir="$SCRIPT_DIR/themes"
    for dir in "$theme_dir"/*/; do
        local name=$(basename "$dir")
        local palette_file="$dir/palette.md"

        # Read first line of palette.md for description
        local desc="No description"
        if [[ -f "$palette_file" ]]; then
            desc=$(head -1 "$palette_file" | sed 's/^# //')
        fi

        # Check if active
        local marker="  "
        local active_theme
        active_theme=$(readlink "$HOME/.config/wavefront/active-theme" 2>/dev/null || echo "")
        if [[ "$active_theme" == *"$name"* ]]; then
            marker="▸ "
        fi

        printf "  %s%-20s %s\n" "$marker" "$name" "$desc"
    done
    echo ""
}

# ─── Switch theme ────────────────────────────────────────────────────────────
switch_theme() {
    local name="$1"
    local theme_path="$SCRIPT_DIR/themes/$name"

    if [[ ! -d "$theme_path" ]]; then
        error "Theme not found: $name"
        info "Available themes:"
        list_themes
        return 1
    fi

    info "Switching to theme: $name"

    # Create wavefront config dir
    mkdir -p "$HOME/.config/wavefront"

    # Update active-theme symlink
    ln -sfn "$theme_path" "$HOME/.config/wavefront/active-theme"

    # Apply kitty colors (if kitty is running)
    if [[ -f "$theme_path/kitty.conf" ]] && command -v kitty &>/dev/null; then
        # kitty @ set-colors reads a color conf file
        kitty @ set-colors --all "$theme_path/kitty.conf" 2>/dev/null || true
        info "Kitty colors updated live (restart for full effect)"
    fi

    # Apply lazygit theme
    if [[ -f "$theme_path/lazygit.yml" ]]; then
        link_config "$theme_path/lazygit.yml" "$HOME/.config/lazygit/config.yml"
    fi

    # Apply btop theme
    if [[ -f "$theme_path/btop.theme" ]]; then
        link_config "$theme_path/btop.theme" "$HOME/.config/btop/themes/active.theme"
    fi

    # Apply delta config
    if [[ -f "$theme_path/delta.gitconfig" ]]; then
        link_config "$theme_path/delta.gitconfig" "$HOME/.config/wavefront/delta.gitconfig"
    fi

    success "Theme switched to: $name"
    info "Some changes may require restarting your terminal"
}

# ─── Restore from backup ────────────────────────────────────────────────────
restore_backup() {
    local ts="$1"
    local backup_dir="$HOME/.config-backups/cli-bootstrap/$ts"

    if [[ ! -d "$backup_dir" ]]; then
        error "Backup not found: $ts"
        info "Available backups:"
        ls -1 "$HOME/.config-backups/cli-bootstrap/" 2>/dev/null || echo "  (none)"
        return 1
    fi

    header "Restoring from backup: $ts"

    if [[ -f "$backup_dir/manifest.txt" ]]; then
        info "Backup manifest:"
        cat "$backup_dir/manifest.txt"
        echo ""
    fi

    if ! ask "Proceed with restore?"; then
        info "Restore cancelled"
        return 0
    fi

    # Read manifest and restore each file
    while IFS='|' read -r original backup_file action; do
        [[ "$original" == "#"* ]] && continue
        [[ -z "$original" ]] && continue

        original=$(echo "$original" | xargs)  # trim whitespace
        backup_file=$(echo "$backup_file" | xargs)

        if [[ -f "$backup_dir/$backup_file" ]]; then
            cp "$backup_dir/$backup_file" "$original"
            success "Restored: $original"
        fi
    done < "$backup_dir/manifest.txt"

    success "Restore complete"
}

# ─── Run a module by name ───────────────────────────────────────────────────
run_module() {
    local name="$1"
    local module_file=""

    # Find the module file
    for entry in "${MODULES[@]}"; do
        IFS=':' read -r num mod_name desc deps <<< "$entry"
        if [[ "$mod_name" == "$name" ]]; then
            module_file="$SCRIPT_DIR/modules/${num}-${name}.sh"
            break
        fi
    done

    if [[ -z "$module_file" || ! -f "$module_file" ]]; then
        error "Module not found: $name"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would run: $module_file"
        return 0
    fi

    # Source and run the module
    source "$module_file"

    if [[ "$YES_MODE" != true ]]; then
        module_explain
        echo ""
        if ! ask "Install and configure $name?"; then
            info "Skipping $name"
            return 0
        fi
    fi

    module_install
    module_configure
    module_verify && success "$name setup complete" || warn "$name setup completed with warnings"
}

# ─── Interactive walkthrough ─────────────────────────────────────────────────
interactive_mode() {
    show_banner

    info "Welcome! This will walk you through setting up a complete CLI environment."
    info "Each step explains what it does and lets you choose."
    echo ""

    # Detect system
    local os pkg
    os=$(detect_os)
    pkg=$(detect_pkg)
    info "Detected: $os with $pkg"
    echo ""

    # Theme selection
    header "Theme"
    info "Your terminal's color identity. You can switch anytime with --theme."
    echo ""
    list_themes
    echo ""
    local theme_choice
    theme_choice=$(ask_input "Which theme? [wavefront]" "wavefront")
    if [[ -d "$SCRIPT_DIR/themes/$theme_choice" ]]; then
        switch_theme "$theme_choice"
    else
        warn "Theme '$theme_choice' not found, using wavefront"
    fi
    echo ""

    # Walk through each module
    local total=${#MODULES[@]}
    local current=0

    for entry in "${MODULES[@]}"; do
        IFS=':' read -r num name desc deps <<< "$entry"
        current=$((current + 1))

        header "[$current/$total] $desc"
        echo ""

        # Check dependencies
        if [[ "$deps" != "none" ]]; then
            info "Dependencies: $deps"
        fi

        run_module "$name"
        echo ""
    done

    # Final verification
    header "Verification"
    source "$SCRIPT_DIR/lib/verify.sh"
    run_verification

    echo ""
    header "All Done!"
    info "Your terminal is now running the Wavefront experience."
    info "Restart your terminal (Cmd+Q, then reopen) for full effect."
    info ""
    info "Quick reference:"
    info "  Switch themes:  ./setup.sh --theme <name>"
    info "  Verify setup:   ./setup.sh --verify"
    info "  Restore backup: ./setup.sh --restore <timestamp>"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    parse_args "$@"

    case "$ACTION" in
        interactive)
            interactive_mode
            ;;
        all)
            show_banner
            info "Installing all modules..."
            echo ""
            for entry in "${MODULES[@]}"; do
                IFS=':' read -r num name desc deps <<< "$entry"
                run_module "$name"
            done
            # Verify
            source "$SCRIPT_DIR/lib/verify.sh"
            run_verification
            ;;
        modules)
            show_banner
            for name in "${SELECTED_MODULES[@]}"; do
                run_module "$name"
            done
            ;;
        list)
            list_modules
            ;;
        themes)
            list_themes
            ;;
        theme)
            switch_theme "$THEME_NAME"
            ;;
        verify)
            source "$SCRIPT_DIR/lib/verify.sh"
            run_verification
            ;;
        restore)
            restore_backup "$RESTORE_TS"
            ;;
    esac
}

main "$@"
