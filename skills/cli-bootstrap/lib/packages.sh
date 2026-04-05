#!/usr/bin/env bash
# packages.sh — Cross-platform package installation abstraction
# Sources common.sh for logging, OS detection, and helpers
set -euo pipefail

# Load shared utilities (resolve relative to this file's location)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# ---------------------------------------------------------------------------
# Package Mapping Table
#
# Format: "tool_name:brew_pkg:apt_pkg:pacman_pkg:is_cask"
#
# Special values:
#   MANUAL  — no native package; handled by a custom install function
#   1       — is_cask field means `brew install --cask` on macOS
#   0       — regular `brew install`
#
# The tool_name is what we check on PATH (via `command -v`), which may
# differ from the package name (e.g. fd-find installs as `fdfind` on Debian).
# ---------------------------------------------------------------------------

PACKAGE_MAP=(
    "iosevka-nf:font-iosevka-term-nerd-font:MANUAL:ttf-iosevka-term-nerd:1"
    "monaspace-nf:font-monaspace-nerd-font:MANUAL:ttf-monaspace-nerd:1"
    "kitty:kitty:kitty:kitty:1"
    "starship:starship:MANUAL:starship:0"
    "bat:bat:bat:bat:0"
    "eza:eza:eza:eza:0"
    "fd:fd:fd-find:fd:0"
    "ripgrep:ripgrep:ripgrep:ripgrep:0"
    "fzf:fzf:fzf:fzf:0"
    "zoxide:zoxide:zoxide:zoxide:0"
    "delta:git-delta:git-delta:git-delta:0"
    "lazygit:lazygit:MANUAL:lazygit:0"
    "btop:btop:btop:btop:0"
    "imagemagick:imagemagick:imagemagick:imagemagick:0"
)

# ---------------------------------------------------------------------------
# Nerd Fonts GitHub release URL (used for MANUAL Linux font installs)
# ---------------------------------------------------------------------------
NERD_FONTS_VERSION="v3.3.0"
NERD_FONTS_BASE="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}"

# ---------------------------------------------------------------------------
# Lookup helper — splits a PACKAGE_MAP entry into parts
# ---------------------------------------------------------------------------

_lookup_pkg() {
    # _lookup_pkg <tool_name>
    # Sets: _BREW _APT _PACMAN _IS_CASK
    local tool="$1"
    for entry in "${PACKAGE_MAP[@]}"; do
        IFS=':' read -r name brew apt pacman cask <<< "$entry"
        if [[ "$name" == "$tool" ]]; then
            _BREW="$brew"
            _APT="$apt"
            _PACMAN="$pacman"
            _IS_CASK="$cask"
            return 0
        fi
    done
    error "Unknown tool: $tool (not in PACKAGE_MAP)"
    return 1
}

# ---------------------------------------------------------------------------
# Homebrew cask-fonts tap — required for font casks on macOS
# ---------------------------------------------------------------------------

ensure_brew_taps() {
    # homebrew/cask-fonts was folded into homebrew/cask in newer brew versions,
    # but the tap is still needed on some setups. We check and tap if missing.
    if ! brew tap | grep -q 'homebrew/cask-fonts' 2>/dev/null; then
        # On newer Homebrew (4.x+), fonts are in homebrew/cask already.
        # Only tap if the formula lookup would fail without it.
        if ! brew info --cask font-iosevka-term-nerd-font &>/dev/null 2>&1; then
            info "Tapping homebrew/cask-fonts..."
            brew tap homebrew/cask-fonts
        fi
    fi
}

# ---------------------------------------------------------------------------
# Linux font installer — downloads a Nerd Font zip from GitHub releases
# ---------------------------------------------------------------------------

install_font_linux() {
    # install_font_linux <zip_name> <dest_folder_name>
    # Example: install_font_linux "IosevkaTerm.zip" "IosevkaTermNF"
    local zip_name="$1"
    local dest_name="$2"
    local font_dir="$HOME/.local/share/fonts/$dest_name"
    local url="${NERD_FONTS_BASE}/${zip_name}"

    require_cmd curl || return 1
    require_cmd unzip || return 1

    local tmp
    tmp="$(mktemp -d)"
    info "Downloading $zip_name from GitHub..."
    curl -fsSL -o "$tmp/$zip_name" "$url"

    mkdir -p "$font_dir"
    unzip -qo "$tmp/$zip_name" -d "$font_dir"

    # Clean up non-font files that ship in the zip (README, LICENSE)
    rm -f "$font_dir"/*.md "$font_dir"/*.txt "$font_dir"/*.rst
    rm -rf "$tmp"

    # Rebuild font cache so apps can find the new fonts immediately
    if command -v fc-cache &>/dev/null; then
        fc-cache -f "$font_dir"
    fi

    success "Installed font: $dest_name → $font_dir"
}

# ---------------------------------------------------------------------------
# Starship installer for apt-based systems (no native .deb package)
# ---------------------------------------------------------------------------

_install_starship_linux() {
    info "Installing starship via official installer..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
}

# ---------------------------------------------------------------------------
# Lazygit installer for apt-based systems (needs PPA or direct binary)
# ---------------------------------------------------------------------------

_install_lazygit_linux() {
    info "Installing lazygit from GitHub releases..."
    require_cmd curl || return 1

    local version
    version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')"

    local tmp
    tmp="$(mktemp -d)"
    local arch
    arch="$(uname -m)"
    # Normalize architecture name for the release asset
    case "$arch" in
        x86_64)  arch="x86_64" ;;
        aarch64) arch="arm64"  ;;
    esac

    curl -fsSL -o "$tmp/lazygit.tar.gz" \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz"
    tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp"
    install "$tmp/lazygit" /usr/local/bin/lazygit
    rm -rf "$tmp"
    success "Installed lazygit v${version}"
}

# ---------------------------------------------------------------------------
# is_installed — check if a tool is available on PATH
# ---------------------------------------------------------------------------

is_installed() {
    # Handles special cases where the binary name differs from the tool name:
    #   - fd-find on Debian/Ubuntu installs as `fdfind`
    #   - font "tools" aren't commands — check via font listing
    local tool="$1"

    case "$tool" in
        fd)
            # Debian ships fd as fdfind to avoid conflict with another `fd` package
            command -v fd &>/dev/null || command -v fdfind &>/dev/null
            ;;
        iosevka-nf|monaspace-nf)
            # Fonts aren't CLI commands — check via font listing
            _is_font_installed "$tool"
            ;;
        delta)
            # git-delta installs the binary as `delta`
            command -v delta &>/dev/null
            ;;
        ripgrep)
            # The binary is `rg`, not `ripgrep`
            command -v rg &>/dev/null
            ;;
        *)
            command -v "$tool" &>/dev/null
            ;;
    esac
}

_is_font_installed() {
    # Check if a Nerd Font family is installed on the system
    local tool="$1"
    local pattern

    case "$tool" in
        iosevka-nf)  pattern="IosevkaTerm.*Nerd" ;;
        monaspace-nf) pattern="Monaspace.*Nerd"   ;;
        *) return 1 ;;
    esac

    local os
    os="$(detect_os)"
    if [[ "$os" == "macos" ]]; then
        # macOS: use the font book system profiler
        system_profiler SPFontsDataType 2>/dev/null | grep -qi "$pattern"
    else
        # Linux: use fc-list
        fc-list 2>/dev/null | grep -qi "$pattern"
    fi
}

# ---------------------------------------------------------------------------
# install_pkg — the main entry point: installs a tool using the right method
# ---------------------------------------------------------------------------

install_pkg() {
    # install_pkg <tool_name>
    # Looks up the package mapping and runs the platform-appropriate install command
    local tool="$1"

    if is_installed "$tool"; then
        success "$tool is already installed"
        return 0
    fi

    _lookup_pkg "$tool"

    local os pkg_mgr
    os="$(detect_os)"
    pkg_mgr="$(detect_pkg)"

    case "$pkg_mgr" in
        brew)
            if [[ "$_BREW" == "MANUAL" ]]; then
                error "No brew package for $tool — manual install needed"
                return 1
            fi
            # Font casks need the tap
            if [[ "$_IS_CASK" == "1" ]]; then
                ensure_brew_taps
                info "Installing $tool (cask: $_BREW)..."
                brew install --cask "$_BREW"
            else
                info "Installing $tool (brew: $_BREW)..."
                brew install "$_BREW"
            fi
            ;;

        apt)
            if [[ "$_APT" == "MANUAL" ]]; then
                # Dispatch to tool-specific manual installers
                case "$tool" in
                    iosevka-nf)
                        install_font_linux "IosevkaTerm.zip" "IosevkaTermNF"
                        ;;
                    monaspace-nf)
                        install_font_linux "Monaspace.zip" "MonaspaceNF"
                        ;;
                    starship)
                        _install_starship_linux
                        ;;
                    lazygit)
                        _install_lazygit_linux
                        ;;
                    *)
                        error "No apt package or manual installer for $tool"
                        return 1
                        ;;
                esac
            else
                info "Installing $tool (apt: $_APT)..."
                sudo apt-get install -y "$_APT"
            fi
            ;;

        pacman)
            if [[ "$_PACMAN" == "MANUAL" ]]; then
                error "No pacman package for $tool — manual install needed"
                return 1
            fi
            info "Installing $tool (pacman: $_PACMAN)..."
            sudo pacman -S --noconfirm "$_PACMAN"
            ;;

        dnf)
            # Fedora — reuse apt package names as a best-effort fallback;
            # most modern CLI tools have the same name in dnf
            info "Installing $tool (dnf: $_APT)..."
            sudo dnf install -y "$_APT"
            ;;

        *)
            error "Unsupported package manager for OS: $os"
            return 1
            ;;
    esac

    # Verify the install actually worked
    if is_installed "$tool"; then
        success "$tool installed successfully"
    else
        error "$tool install command ran but binary not found on PATH"
        return 1
    fi
}
