#!/usr/bin/env bash
# Module: Zsh — plugins and Wavefront shell configuration
# Dependencies: starship (03), cli-tools (08)
# Configs: wavefront.zsh → ~/.config/wavefront/wavefront.zsh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"

MODULE_NAME="zsh"
MODULE_DESC="Install zsh plugins and configure Wavefront shell additions"

module_explain() {
    header "Zsh — Shell plugins and Wavefront integration"

    info "Zsh is the default shell on macOS and the most flexible shell for"
    info "interactive use on Linux. The shell itself is already installed —"
    info "this module adds two essential plugins and the Wavefront config."
    info ""

    info "Plugins installed:"
    info "  • zsh-autosuggestions — shows ghost text of your most recent matching"
    info "    command as you type. Press → to accept. Saves enormous amounts of"
    info "    retyping for long commands."
    info "  • zsh-syntax-highlighting — colors your command line in real-time."
    info "    Valid commands turn green, errors turn red, strings get quoted colors."
    info "    You catch typos before hitting Enter."
    info ""

    info "The Wavefront approach:"
    info "  wavefront.zsh is a SINGLE standalone file sourced from your .zshrc."
    info "  It contains all Wavefront-specific config: aliases, colors, FZF theme,"
    info "  greeter, starship init, and transient prompt."
    info ""
    info "  It NEVER touches your existing .zshrc content — no PATH modifications,"
    info "  no NVM rewrites, no history changes. Just one 'source' line appended."
    info "  If you don't like it, remove that one line and everything reverts."
}

module_install() {
    local os
    os="$(detect_os)"

    case "$os" in
        macos)
            info "Installing zsh plugins via Homebrew..."
            brew install zsh-autosuggestions zsh-syntax-highlighting
            ;;
        ubuntu|debian)
            info "Installing zsh plugins via apt..."
            sudo apt-get install -y zsh-autosuggestions zsh-syntax-highlighting
            ;;
        fedora)
            info "Installing zsh plugins via dnf..."
            sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting
            ;;
        arch)
            info "Installing zsh plugins via pacman..."
            sudo pacman -S --noconfirm zsh-autosuggestions zsh-syntax-highlighting
            ;;
        *)
            # Fallback: clone directly into ~/.zsh/
            warn "Unknown package manager. Installing plugins to ~/.zsh/ via git clone..."
            mkdir -p "$HOME/.zsh"
            git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions" 2>/dev/null || true
            git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting" 2>/dev/null || true
            ;;
    esac
}

module_configure() {
    local source_file="$SCRIPT_DIR/configs/zsh/wavefront.zsh"
    local dest_dir="$HOME/.config/wavefront"
    local dest_file="$dest_dir/wavefront.zsh"
    local zshrc="$HOME/.zshrc"

    # Copy (not symlink) wavefront.zsh — users may want to tweak it locally
    # without modifying the repo. The canonical version lives in configs/.
    copy_config "$source_file" "$dest_file"

    # Append source line to .zshrc if not already present.
    # We grep for the exact path to avoid false positives.
    local source_line='source ~/.config/wavefront/wavefront.zsh'
    if [[ -f "$zshrc" ]] && grep -qF "$source_line" "$zshrc"; then
        info "Source line already present in $zshrc — skipping."
    else
        # Add a comment so the user knows what this line is
        {
            echo ""
            echo "# Wavefront terminal customization"
            echo "$source_line"
        } >> "$zshrc"
        success "Appended source line to $zshrc"
    fi
}

module_verify() {
    local ok=0
    local zshrc="$HOME/.zshrc"
    local source_line='source ~/.config/wavefront/wavefront.zsh'

    # Check plugins are available (not necessarily loaded — we're in bash here)
    local os
    os="$(detect_os)"
    case "$os" in
        macos)
            if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
                success "zsh-autosuggestions plugin found"
            else
                warn "zsh-autosuggestions not found at expected Homebrew path"
                ok=1
            fi
            if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
                success "zsh-syntax-highlighting plugin found"
            else
                warn "zsh-syntax-highlighting not found at expected Homebrew path"
                ok=1
            fi
            ;;
        *)
            # Linux: check common paths
            local found_auto=0 found_syn=0
            for p in /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
                     /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
                     "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
                [[ -f "$p" ]] && found_auto=1
            done
            for p in /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
                     /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
                     "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
                [[ -f "$p" ]] && found_syn=1
            done
            (( found_auto )) && success "zsh-autosuggestions found" || { warn "zsh-autosuggestions not found"; ok=1; }
            (( found_syn )) && success "zsh-syntax-highlighting found" || { warn "zsh-syntax-highlighting not found"; ok=1; }
            ;;
    esac

    # Check wavefront.zsh exists
    if [[ -f "$HOME/.config/wavefront/wavefront.zsh" ]]; then
        success "wavefront.zsh present at ~/.config/wavefront/wavefront.zsh"
    else
        warn "wavefront.zsh not found"
        ok=1
    fi

    # Check source line in .zshrc
    if [[ -f "$zshrc" ]] && grep -qF "$source_line" "$zshrc"; then
        success "Source line present in $zshrc"
    else
        warn "Source line missing from $zshrc"
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
