# CLI Bootstrap — Bazzite/Immutable OS Gotchas & Skill Improvements

Ledger of issues encountered running this skill on Bazzite (Fedora Atomic/immutable).
Use this to improve the skill for immutable distro support.

---

## 1. OS Detection fails on derivatives
- **Problem:** `detect_os()` only checks `$ID`, not `$ID_LIKE`. Bazzite (`ID=bazzite`) returns "unknown".
- **Fix applied:** Fall back to `ID_LIKE` in `lib/common.sh`.
- **Skill improvement:** Always check `ID_LIKE` for derivatives (Bazzite, Nobara, Ultramarine, etc).

## 2. `dnf install` is blocked on immutable Fedora
- **Problem:** Bazzite blocks `dnf install` — root filesystem is read-only. `rpm-ostree` requires reboot.
- **Fix applied:** Changed `detect_pkg()` to prefer `brew` when available on Linux.
- **Skill improvement:** Add immutable OS detection (check for `rpm-ostree` or `/run/ostree-booted`). If detected, prefer brew > official installer > rpm-ostree. Never default to dnf.

## 3. Kitty has no Flatpak, no Linux brew formula, macOS-only cask
- **Problem:** On immutable OS, GUI app install options are limited. Kitty's author refuses Flatpak. brew cask is macOS-only.
- **Outcome:** Switched to Ghostty (AppImage) instead.
- **Skill improvement:** The skill is too coupled to Kitty. Should support multiple terminal backends (Kitty, Ghostty, WezTerm). Terminal-specific features (kittens, icat, cursor trails) should be optional modules, not baked into the core config.

## 4. Ghostty config file name changed in v1.2.3+
- **Problem:** Ghostty ≥1.2.3 expects `config.ghostty`, not `config`. Both should exist for compatibility.
- **Skill improvement:** If adding Ghostty support, write both filenames or detect version.

## 5. zsh `$path` variable destroys `$PATH`
- **Problem:** `_wf_try_source()` in wavefront.zsh uses `for path in "$@"`. In zsh, `$path` is a tied array to `$PATH` — the loop nukes PATH on every iteration. Every external command fails.
- **Root cause:** Skill author didn't account for zsh special variables.
- **Fix:** Rename loop var to `_wf_p`.
- **Skill improvement:** Audit all variable names in zsh scripts against zsh special variables (`path`, `cdpath`, `fpath`, `manpath`, `module_path`, `mailpath`).

## 6. Homebrew zsh doesn't inherit system PATH
- **Problem:** brew-installed zsh starts with minimal PATH. Without `.zshenv` setting up PATH, system commands aren't found.
- **Skill improvement:** The zsh module should create `.zshenv` with system PATH, not just append to `.zshrc`.

## 7. zsh was cargo-culted — bash works fine
- **Problem:** The skill forces zsh but the actual value is in the tools + theme + aliases. The user was already on bash. Switching shells introduced unnecessary complexity and bugs.
- **Skill improvement:** Shell config should be shell-agnostic or support both bash/zsh. Detect the user's current shell and generate config for that. Don't force a shell switch.

## 8. Ghostty keybind syntax differs from Kitty
- **Problem:** `bracketright`, `bracketleft`, `ctrl+tab` keybinds caused InvalidFormat errors in Ghostty.
- **Skill improvement:** If supporting multiple terminals, keybind configs must be per-terminal.

## 9. Desktop file registration for non-package installs
- **Problem:** Kitty official installer and Ghostty AppImage don't register .desktop files. App doesn't show in launcher.
- **Fix:** Manually extract and register desktop file + icon.
- **Skill improvement:** Any non-package install should include desktop file registration as a post-install step.

## 10. Interactive script can't run non-interactively
- **Problem:** `setup.sh` uses `ask()` prompts that break when run from a non-TTY (e.g., Claude Code's bash tool). Theme selection prompt garbled the input.
- **Skill improvement:** `ask()` should detect non-TTY and auto-accept defaults. `--yes` mode should be more robust.

---

## Architectural Recommendations for v2

1. **Detect immutable OS early** — check `/run/ostree-booted` or `rpm-ostree status` and set package strategy accordingly
2. **Terminal-agnostic core** — separate "theme + tools + aliases" from "terminal emulator config"
3. **Shell-agnostic aliases** — write both `.bashrc` and `.zshrc` snippets, or use a POSIX-compatible approach
4. **Multiple terminal backends** — Kitty, Ghostty, WezTerm configs as separate optional modules
5. **Don't force shell changes** — detect and enhance the user's existing shell
