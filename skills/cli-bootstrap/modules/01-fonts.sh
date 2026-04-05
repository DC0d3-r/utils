#!/usr/bin/env bash
# Module: Fonts — Nerd Font installation (IosevkaTerm + MonaspiceRn)
# Dependencies: none
# Configs: none (fonts are system-level)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="fonts"
MODULE_DESC="Install Nerd Fonts — IosevkaTerm (monospace) + MonaspiceRn (italic comments)"

module_explain() {
    header "Fonts — Why Nerd Fonts?"

    info "Nerd Fonts are patched versions of developer fonts that include thousands"
    info "of icons — file type glyphs, git symbols, powerline arrows, and more."
    info "Without them, your terminal and prompt will show broken □ squares instead"
    info "of the icons that tools like eza, starship, and lazygit rely on."
    info ""

    info "Primary font: IosevkaTerm Nerd Font"
    info "  Iosevka has a narrow, Japanese-inspired geometry — characters are tall and"
    info "  compact, giving you more columns per screen. Perfect for split panes."
    info "  The 'Term' variant disables ligatures, so your terminal cursor stays sane."
    info ""

    info "Italic font: MonaspiceRn Nerd Font (Monaspace Radon)"
    info "  Monaspace is GitHub's font family. 'Radon' is the handwritten variant —"
    info "  it gives code comments a distinctive texture, like margin notes in a book."
    info "  Kitty can assign this as the italic font face, so comments stand apart."
    info ""

    info "Alternatives considered:"
    info "  • JetBrains Mono — excellent, but wider glyphs = fewer columns in splits"
    info "  • Fira Code — rounder shapes, less vertical density"
    info "  • Cascadia Code — great on Windows/VS Code, less common in terminal setups"
    info "  All are good fonts. Iosevka wins on information density."
}

module_install() {
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            info "Installing fonts via Homebrew casks..."
            brew install --cask font-iosevka-term-nerd-font font-monaspace-nerd-font
            ;;
        ubuntu|debian|fedora|arch)
            # Linux: download from GitHub releases and install to user font dir
            local font_dir="$HOME/.local/share/fonts"
            mkdir -p "$font_dir"

            local nf_base="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

            info "Downloading IosevkaTerm Nerd Font..."
            local iosevka_zip="/tmp/IosevkaTermNerdFont.zip"
            curl -fsSL "$nf_base/IosevkaTerm.zip" -o "$iosevka_zip"
            unzip -o "$iosevka_zip" -d "$font_dir/IosevkaTermNerdFont/"

            info "Downloading Monaspace Nerd Font..."
            local monaspace_zip="/tmp/MonaspaceNerdFont.zip"
            curl -fsSL "$nf_base/Monaspace.zip" -o "$monaspace_zip"
            unzip -o "$monaspace_zip" -d "$font_dir/MonaspaceNerdFont/"

            # Rebuild the font cache so applications can find them immediately
            info "Rebuilding font cache..."
            fc-cache -fv
            success "Fonts installed to $font_dir"
            ;;
        *)
            error "Unsupported OS. Download Nerd Fonts manually from:"
            info "  https://github.com/ryanoasis/nerd-fonts/releases"
            return 1
            ;;
    esac
}

module_configure() {
    # Fonts don't have config files — they're system-level resources.
    # The font names are referenced in kitty.conf (handled by 02-kitty.sh).
    info "No configuration needed — fonts are referenced by kitty.conf and starship.toml."
}

module_verify() {
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            # system_profiler SPFontsDataType is very slow (~10s). Just check
            # that brew reports the casks as installed.
            if brew list --cask font-iosevka-term-nerd-font &>/dev/null \
                && brew list --cask font-monaspace-nerd-font &>/dev/null; then
                success "IosevkaTerm NF and MonaspiceRn NF installed (Homebrew casks present)"
                return 0
            else
                error "Font casks not found. Run module_install first."
                return 1
            fi
            ;;
        *)
            # Linux: check fc-list for font family names
            local ok=0
            if fc-list | grep -qi "IosevkaTerm"; then
                success "IosevkaTerm Nerd Font found in font cache"
            else
                warn "IosevkaTerm Nerd Font NOT found in font cache"
                ok=1
            fi
            if fc-list | grep -qi "MonaspiceRn\|Monaspace Radon"; then
                success "MonaspiceRn Nerd Font found in font cache"
            else
                warn "MonaspiceRn Nerd Font NOT found in font cache"
                ok=1
            fi
            return $ok
            ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    module_explain
    ask "Install $MODULE_NAME?" "y" && module_install
    module_configure
    module_verify
fi
