#!/usr/bin/env bash
# common.sh — Core utilities for the cli-bootstrap skill
# Provides: OS detection, logging (Wavefront colors), backup, symlink, interactive prompts, theming
set -euo pipefail

WAVEFRONT_VERSION="1.0"

# Resolve SCRIPT_DIR to the cli-bootstrap root (one level up from lib/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# OS & Package Manager Detection
# ---------------------------------------------------------------------------

detect_os() {
    # Returns a normalized OS identifier: macos | ubuntu | debian | fedora | arch | unknown
    case "$(uname -s)" in
        Darwin) echo "macos"; return ;;
    esac

    # Linux — read /etc/os-release for distro ID
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        case "${ID:-}" in
            ubuntu)       echo "ubuntu" ;;
            debian)       echo "debian" ;;
            fedora)       echo "fedora" ;;
            arch|manjaro) echo "arch"   ;;   # manjaro is arch-based
            *)            echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

detect_pkg() {
    # Returns the primary package manager for this OS
    local os
    os="$(detect_os)"
    case "$os" in
        macos)         echo "brew"    ;;
        ubuntu|debian) echo "apt"     ;;
        fedora)        echo "dnf"     ;;
        arch)          echo "pacman"  ;;
        *)             echo "unknown" ;;
    esac
}

require_cmd() {
    # Usage: require_cmd git
    # Prints a warning and returns 1 if the command is missing
    local name="$1"
    if ! command -v "$name" &>/dev/null; then
        warn "'$name' is not installed or not in PATH"
        return 1
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Logging — Wavefront theme colors (ANSI 256-color approximations)
#
# crystalBlue #7E9CD8 → 110     mossGreen #7BA888 → 108
# sandGold    #C4B28A → 180     autumnLeaf #D0605A → 167
# fujiWhite   #DCD7BA → 187     sumiInk    #1F1F28 → 234
# ---------------------------------------------------------------------------

_color() {
    # _color <256-color-code> <text>
    # Wraps text in ANSI escape codes; gracefully degrades if not a terminal
    if [[ -t 1 ]]; then
        printf '\033[38;5;%sm%s\033[0m' "$1" "$2"
    else
        printf '%s' "$2"
    fi
}

info() {
    # [info] in crystalBlue
    printf '%s %s\n' "$(_color 110 '[info]')" "$*"
}

success() {
    # [ok] in mossGreen
    printf '%s %s\n' "$(_color 108 '[ok]')" "$*"
}

warn() {
    # [warn] in sandGold — goes to stderr so it doesn't pollute piped output
    printf '%s %s\n' "$(_color 180 '[warn]')" "$*" >&2
}

error() {
    # [error] in autumnLeaf — goes to stderr
    printf '%s %s\n' "$(_color 167 '[error]')" "$*" >&2
}

step() {
    # step <num> <total> <msg>  →  [2/9] Installing fonts...
    local num="$1" total="$2"; shift 2
    local label
    label="$(_color 110 "[$num/$total]")"
    printf '%s %s\n' "$label" "$*"
}

header() {
    # Section header with ─── lines for visual separation
    local msg="$1"
    local line
    line="$(_color 187 '───────────────────────────────')"
    printf '\n%s\n  %s\n%s\n' "$line" "$(_color 187 "$msg")" "$line"
}

# ---------------------------------------------------------------------------
# Backup — stash existing configs before overwriting
# ---------------------------------------------------------------------------

# BACKUP_DIR is set lazily on first call and reused for the entire session
# so all backed-up files from one run share a single timestamped folder.
BACKUP_DIR=""

_init_backup_dir() {
    if [[ -z "$BACKUP_DIR" ]]; then
        local ts
        ts="$(date '+%Y%m%d-%H%M%S')"
        BACKUP_DIR="$HOME/.config-backups/cli-bootstrap/$ts"
        mkdir -p "$BACKUP_DIR"
        info "Backup dir: $BACKUP_DIR"
    fi
}

backup_config() {
    # backup_config <file>
    # Copies the file into the session backup dir and appends to manifest.txt
    local file="$1"

    # Nothing to back up if the file doesn't exist
    [[ -f "$file" || -L "$file" ]] || return 0

    _init_backup_dir

    # Preserve the relative path structure inside the backup dir
    # e.g. ~/.config/kitty/kitty.conf → <backup>/config/kitty/kitty.conf
    local relative
    relative="${file#"$HOME"/}"  # strip leading ~/
    local dest="$BACKUP_DIR/$relative"

    mkdir -p "$(dirname "$dest")"
    cp -aL "$file" "$dest"  # -a preserves perms, -L dereferences symlinks

    # Append to manifest for easy review later
    echo "$file → $dest" >> "$BACKUP_DIR/manifest.txt"
    info "Backed up: $file"
}

# ---------------------------------------------------------------------------
# Symlink / Copy — with automatic backup and parent-dir creation
# ---------------------------------------------------------------------------

link_config() {
    # link_config <source> <dest>
    # Backs up existing dest, creates parent dirs, then symlinks source → dest
    local source="$1" dest="$2"

    if [[ ! -e "$source" ]]; then
        error "Source does not exist: $source"
        return 1
    fi

    # Back up whatever is currently at dest
    backup_config "$dest"

    # Remove existing file/symlink so ln doesn't fail
    [[ -e "$dest" || -L "$dest" ]] && rm -f "$dest"

    mkdir -p "$(dirname "$dest")"
    ln -sf "$source" "$dest"
    success "Linked: $dest → $source"
}

copy_config() {
    # copy_config <source> <dest>
    # Same as link_config but copies instead of symlinking
    local source="$1" dest="$2"

    if [[ ! -e "$source" ]]; then
        error "Source does not exist: $source"
        return 1
    fi

    backup_config "$dest"
    [[ -e "$dest" || -L "$dest" ]] && rm -f "$dest"

    mkdir -p "$(dirname "$dest")"
    cp -a "$source" "$dest"
    success "Copied: $source → $dest"
}

# ---------------------------------------------------------------------------
# Interactive — prompts that respect YES_MODE for unattended runs
# ---------------------------------------------------------------------------

# Set YES_MODE=1 (via --yes flag) to auto-accept all prompts
YES_MODE="${YES_MODE:-0}"

ask() {
    # ask "Install fonts?" [y]  → returns 0 for yes, 1 for no
    local prompt="$1"
    local default="${2:-y}"

    # Auto-accept in non-interactive mode
    if [[ "$YES_MODE" == "true" || "$YES_MODE" == "1" ]]; then
        return 0
    fi

    local hint
    if [[ "$default" == "y" ]]; then
        hint="[Y/n]"
    else
        hint="[y/N]"
    fi

    printf '%s %s ' "$(_color 110 '?')" "$prompt $hint"
    read -r answer
    answer="${answer:-$default}"

    case "${answer,,}" in   # ${,,} lowercases the string (bash 4+)
        y|yes) return 0 ;;
        *)     return 1 ;;
    esac
}

ask_input() {
    # ask_input "Which theme?" "wavefront"  → prints prompt, returns answer (or default)
    local prompt="$1"
    local default="${2:-}"

    # In non-interactive mode, return the default
    if [[ "$YES_MODE" == "true" || "$YES_MODE" == "1" ]]; then
        echo "$default"
        return 0
    fi

    local hint=""
    [[ -n "$default" ]] && hint=" [$default]"
    printf '%s %s%s: ' "$(_color 110 '?')" "$prompt" "$hint"
    read -r answer
    echo "${answer:-$default}"
}

choose() {
    # choose "Pick a theme:" "kanagawa" "rosepine" "catppuccin"
    # Prints numbered menu, returns selected index (0-based) via $CHOSEN
    local prompt="$1"; shift
    local options=("$@")

    printf '\n%s\n' "$(_color 110 "$prompt")"
    local i
    for i in "${!options[@]}"; do
        printf '  %s) %s\n' "$(_color 180 "$((i + 1))")" "${options[$i]}"
    done

    local selection
    while true; do
        printf '%s ' "$(_color 110 '#')"
        read -r selection

        # Validate: must be a number within range
        if [[ "$selection" =~ ^[0-9]+$ ]] \
            && (( selection >= 1 && selection <= ${#options[@]} )); then
            CHOSEN=$(( selection - 1 ))
            return 0
        fi
        warn "Enter a number between 1 and ${#options[@]}"
    done
}

# ---------------------------------------------------------------------------
# Theme — activate a Wavefront theme variant
# ---------------------------------------------------------------------------

apply_theme() {
    # apply_theme <name>  — e.g. apply_theme kanagawa
    # Symlinks the named theme dir into ~/.config/wavefront/active-theme
    local name="$1"
    local theme_dir="$SCRIPT_DIR/themes/$name"
    local active_link="$HOME/.config/wavefront/active-theme"

    if [[ ! -d "$theme_dir" ]]; then
        error "Theme not found: $theme_dir"
        return 1
    fi

    mkdir -p "$HOME/.config/wavefront"
    [[ -L "$active_link" ]] && rm -f "$active_link"
    ln -sf "$theme_dir" "$active_link"
    success "Active theme: $name"
}
