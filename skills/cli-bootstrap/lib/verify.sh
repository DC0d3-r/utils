#!/usr/bin/env bash
# verify.sh — Post-install verification for the Wavefront CLI bootstrap
# Sources common.sh for logging and OS detection
set -euo pipefail

# Load shared utilities
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# ---------------------------------------------------------------------------
# Counters — tracked globally so check functions can increment them
# ---------------------------------------------------------------------------
_PASS=0
_FAIL=0
_WARN=0

# Return codes used by individual check functions
_RC_PASS=0
_RC_FAIL=1
_RC_WARN=2

_record() {
    # _record <return_code>
    # Increments the appropriate counter based on a check's exit status
    case "$1" in
        0) (( _PASS++ )) ;;
        1) (( _FAIL++ )) ;;
        2) (( _WARN++ )) ;;
    esac
}

_check_pass() {
    success "[PASS] $*"
    return $_RC_PASS
}

_check_fail() {
    error "[FAIL] $*"
    return $_RC_FAIL
}

_check_warn() {
    warn "[WARN] $*"
    return $_RC_WARN
}

# ---------------------------------------------------------------------------
# Individual verification functions
# Each returns 0 (pass), 1 (fail), or 2 (warn)
# ---------------------------------------------------------------------------

verify_fonts() {
    # Check for IosevkaTerm NF and MonaspiceRn NF (Monaspace variant)
    local os
    os="$(detect_os)"
    local rc=0

    if [[ "$os" == "macos" ]]; then
        # macOS: system_profiler is slow but authoritative
        local font_list
        font_list="$(system_profiler SPFontsDataType 2>/dev/null)"

        if echo "$font_list" | grep -qi "IosevkaTerm.*Nerd"; then
            _check_pass "IosevkaTerm NF font found"
            _record 0
        else
            _check_fail "IosevkaTerm NF font not found"
            _record 1; rc=1
        fi

        if echo "$font_list" | grep -qi "Monaspace.*Nerd\|MonaspiceRn.*Nerd"; then
            _check_pass "MonaspiceRn NF font found"
            _record 0
        else
            _check_fail "MonaspiceRn NF font not found"
            _record 1; rc=1
        fi
    else
        # Linux: fc-list is fast and reliable
        if fc-list 2>/dev/null | grep -qi "IosevkaTerm.*Nerd"; then
            _check_pass "IosevkaTerm NF font found"
            _record 0
        else
            _check_fail "IosevkaTerm NF font not found"
            _record 1; rc=1
        fi

        if fc-list 2>/dev/null | grep -qi "Monaspace.*Nerd\|MonaspiceRn.*Nerd"; then
            _check_pass "MonaspiceRn NF font found"
            _record 0
        else
            _check_fail "MonaspiceRn NF font not found"
            _record 1; rc=1
        fi
    fi

    return $rc
}

verify_kitty() {
    local rc=0

    if command -v kitty &>/dev/null; then
        local ver
        ver="$(kitty --version 2>/dev/null | head -1)"
        _check_pass "Kitty installed ($ver)"
        _record 0
    else
        _check_fail "Kitty not installed"
        _record 1; rc=1
    fi

    if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
        _check_pass "kitty.conf present at ~/.config/kitty/kitty.conf"
        _record 0
    else
        _check_fail "kitty.conf missing at ~/.config/kitty/kitty.conf"
        _record 1; rc=1
    fi

    return $rc
}

verify_starship() {
    local rc=0

    if command -v starship &>/dev/null; then
        local ver
        ver="$(starship --version 2>/dev/null | head -1)"
        _check_pass "Starship installed ($ver)"
        _record 0
    else
        _check_fail "Starship not installed"
        _record 1; rc=1
    fi

    if [[ -f "$HOME/.config/starship.toml" ]]; then
        _check_pass "starship.toml present at ~/.config/starship.toml"
        _record 0
    else
        _check_fail "starship.toml missing at ~/.config/starship.toml"
        _record 1; rc=1
    fi

    return $rc
}

verify_zsh() {
    local rc=0

    # Check if wavefront.zsh is sourced from .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        if grep -q 'wavefront\.zsh\|wavefront/zsh' "$HOME/.zshrc" 2>/dev/null; then
            _check_pass "wavefront.zsh sourced from .zshrc"
            _record 0
        else
            _check_fail "wavefront.zsh not sourced in .zshrc"
            _record 1; rc=1
        fi
    else
        _check_fail ".zshrc not found"
        _record 1; rc=1
    fi

    return $rc
}

verify_delta() {
    local rc=0

    if command -v delta &>/dev/null; then
        _check_pass "delta installed"
        _record 0
    else
        _check_fail "delta not installed"
        _record 1; rc=1
    fi

    # Check git config for delta as pager
    local pager
    pager="$(git config --global core.pager 2>/dev/null || true)"
    if [[ "$pager" == "delta" ]]; then
        _check_pass "git core.pager = delta"
        _record 0
    else
        _check_fail "git core.pager is '${pager:-unset}', expected 'delta'"
        _record 1; rc=1
    fi

    return $rc
}

verify_lazygit() {
    local rc=0

    if command -v lazygit &>/dev/null; then
        _check_pass "lazygit installed"
        _record 0
    else
        _check_fail "lazygit not installed"
        _record 1; rc=1
    fi

    # Check for config file (lazygit uses ~/Library/Application Support on macOS,
    # ~/.config/lazygit on Linux)
    local config_path
    local os
    os="$(detect_os)"
    if [[ "$os" == "macos" ]]; then
        config_path="$HOME/Library/Application Support/lazygit/config.yml"
    else
        config_path="$HOME/.config/lazygit/config.yml"
    fi

    if [[ -f "$config_path" ]]; then
        _check_pass "lazygit config present"
        _record 0
    else
        # Config is optional — lazygit works fine with defaults
        _check_warn "lazygit config not found at $config_path (optional)"
        _record 2; rc=2
    fi

    return $rc
}

verify_btop() {
    local rc=0

    if command -v btop &>/dev/null; then
        _check_pass "btop installed"
        _record 0
    else
        _check_fail "btop not installed"
        _record 1; rc=1
    fi

    # Check for Wavefront theme file
    local theme_path="$HOME/.config/btop/themes/wavefront.theme"
    if [[ -f "$theme_path" ]]; then
        _check_pass "btop wavefront theme present"
        _record 0
    else
        _check_warn "btop wavefront theme missing at $theme_path (optional)"
        _record 2
        # Only warn — btop works without a custom theme
        [[ $rc -eq 0 ]] && rc=2
    fi

    return $rc
}

verify_cli_tools() {
    # Bulk-check the core CLI tools: bat, eza, fd, rg, fzf, zoxide
    local rc=0

    local -A tool_cmds=(
        [bat]="bat"
        [eza]="eza"
        [fd]="fd"
        [ripgrep]="rg"
        [fzf]="fzf"
        [zoxide]="zoxide"
    )

    for tool in bat eza fd ripgrep fzf zoxide; do
        local cmd="${tool_cmds[$tool]}"

        # fd has an alias on Debian (fdfind)
        if [[ "$tool" == "fd" ]]; then
            if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
                _check_pass "$tool installed"
                _record 0
            else
                _check_fail "$tool not installed"
                _record 1; rc=1
            fi
        elif command -v "$cmd" &>/dev/null; then
            _check_pass "$tool installed"
            _record 0
        else
            _check_fail "$tool not installed"
            _record 1; rc=1
        fi
    done

    return $rc
}

verify_greeter() {
    # The greeter image is an optional kitty background / welcome screen asset
    local rc=0

    # Check common locations for the greeter image
    local found=0
    local search_paths=(
        "$HOME/.config/kitty/greeter.png"
        "$HOME/.config/wavefront/greeter.png"
        "$SCRIPT_DIR/assets/greeter.png"
    )

    for path in "${search_paths[@]}"; do
        if [[ -f "$path" ]]; then
            _check_pass "Greeter image present at $path"
            _record 0
            found=1
            break
        fi
    done

    if [[ "$found" -eq 0 ]]; then
        _check_warn "Greeter image missing (optional)"
        _record 2; rc=2
    fi

    return $rc
}

# ---------------------------------------------------------------------------
# run_verification — the main entry point
# ---------------------------------------------------------------------------

run_verification() {
    # run_verification [modules...]
    # If modules are specified, only runs those checks.
    # If none specified, runs all checks.
    local modules=("$@")

    # Reset counters for this run
    _PASS=0
    _FAIL=0
    _WARN=0

    header "Wavefront Setup Verification"

    # Map of available verification modules
    local all_modules=(fonts kitty starship zsh delta lazygit btop cli_tools greeter)

    # If no specific modules requested, run everything
    if [[ ${#modules[@]} -eq 0 ]]; then
        modules=("${all_modules[@]}")
    fi

    for mod in "${modules[@]}"; do
        # Normalize: allow both "cli-tools" and "cli_tools"
        mod="${mod//-/_}"

        case "$mod" in
            fonts)      verify_fonts     || true ;;
            kitty)      verify_kitty     || true ;;
            starship)   verify_starship  || true ;;
            zsh)        verify_zsh       || true ;;
            delta)      verify_delta     || true ;;
            lazygit)    verify_lazygit   || true ;;
            btop)       verify_btop      || true ;;
            cli_tools)  verify_cli_tools || true ;;
            greeter)    verify_greeter   || true ;;
            *)
                warn "Unknown verification module: $mod"
                ;;
        esac
    done

    # Print summary
    local total=$(( _PASS + _FAIL + _WARN ))
    printf '\n'
    header "Results"

    local summary="${_PASS}/${total} checks passed"
    [[ $_WARN -gt 0 ]] && summary="$summary, $_WARN warning(s)"
    [[ $_FAIL -gt 0 ]] && summary="$summary, $_FAIL failed"

    if [[ $_FAIL -eq 0 ]]; then
        success "$summary"
    else
        error "$summary"
    fi

    # Return non-zero if any checks failed (warnings are OK)
    [[ $_FAIL -eq 0 ]]
}
