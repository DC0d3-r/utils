# Troubleshooting

## Fonts

### Boxes/tofu instead of icons
Nerd Font icons require a compatible font. After installing:
- **macOS:** Restart Kitty completely (`Cmd+Q`, not just reload)
- **Linux:** Run `fc-cache -fv` then restart Kitty

### Font not found by name
Nerd Fonts use non-obvious naming. The font file "Monaspace Radon" becomes `MonaspiceRn NF` in Kitty config. Check exact names:
```bash
# macOS
system_profiler SPFontsDataType 2>/dev/null | grep -i iosevka

# Linux
fc-list | grep -i iosevka
```

### Wrong font style in italic
If italic comments don't look handwritten, check that `MonaspiceRn NF Italic` is installed (not just the regular weight). Kitty falls back silently to the primary font if the italic variant is missing.

## Kitty

### Config reload doesn't apply all changes
`Cmd+Shift+R` reloads colors and layout but NOT:
- Font changes (need full restart)
- Window decoration changes (need full restart)
- Tab bar style changes (need full restart)

Always `Cmd+Q` then reopen for font/decoration changes.

### Background image not showing
1. Check the file exists: `ls ~/Pictures/kitty-backgrounds/wavefront-noise.png`
2. Generate it: `./assets/backgrounds/generate-noise.sh`
3. Verify kitty.conf points to the right path (should use `~` not absolute)

### Cursor trail not visible
Cursor trail requires Kitty 0.35+. Check: `kitty --version`. The trail uses warm gold (#C8C093) which is subtle by design — it's most visible during fast cursor movement.

## Starship Prompt

### Prompt not showing
Check starship is initialized in your shell:
```bash
# Should output the init script
starship init zsh
```
If using wavefront.zsh, it handles this automatically. If manually configured, ensure `eval "$(starship init zsh)"` is near the END of .zshrc (after other shell setup).

### Transient prompt not working
The transient prompt (collapsing to `>` after command execution) requires:
1. Starship 1.17+ 
2. `STARSHIP_TRANSIENT_PROMPT_COMMAND` set AFTER `starship init zsh`
3. Both are handled by wavefront.zsh

### Wrong colors in prompt
Ensure `palette = "wavefront"` is set in starship.toml and the `[palettes.wavefront]` section exists. If using a different theme, change the palette name.

## Delta (Git Diffs)

### Git diff still plain text
Check git is configured to use delta:
```bash
git config --get core.pager  # Should output: delta
```
If not, ensure your .gitconfig includes the delta config:
```bash
git config --global include.path "~/.config/wavefront/delta.gitconfig"
```

### Side-by-side too narrow
Delta auto-adjusts to terminal width. If columns are too narrow in side-by-side mode, widen your terminal or use `git diff --no-ext-diff` for a single-column fallback.

## Shell

### Aliases not working (bat, eza, fd, rg)
The CLI tool aliases only activate if the tools are installed. Check:
```bash
command -v bat eza fd rg fzf zoxide
```
Install missing tools: `./setup.sh --module cli-tools`

### Plugin colors not showing
zsh-syntax-highlighting must be sourced BEFORE the color definitions take effect. wavefront.zsh handles the order, but if you source plugins elsewhere in .zshrc, the order might conflict.

### FZF Ctrl-R not working
FZF shell integration needs to be sourced. wavefront.zsh handles this with `eval "$(fzf --zsh)"` (fzf 0.48+). For older fzf, source the key-bindings file manually.

## SSH Sessions

### Colors wrong over SSH
The `ssh` alias sets `TERM=xterm-256color`. For full kitty support:
```bash
kitty +kitten ssh user@host
```
This copies kitty's terminfo to the remote host automatically.

### Greeter showing over SSH
The greeter checks for `$KITTY_PID` — it should auto-skip in SSH. If it doesn't, check that you're not forwarding the KITTY_PID environment variable.

## Theme Switching

### Colors not updating after theme switch
- Kitty: `setup.sh --theme` sends live color updates via `kitty @`. Full restart for complete effect.
- Btop: Restart btop after theme switch
- Lazygit: Restart lazygit after theme switch
- FZF: New shell sessions pick up new colors automatically
- Starship: Edit `starship.toml` palette name manually for now

## Platform-Specific

### macOS: `fd` command not found
Homebrew installs fd as `fd`. Should work out of the box.

### Linux (Ubuntu): `fd` command not found
apt installs as `fd-find` with binary `fdfind`. Create a symlink:
```bash
sudo ln -s $(which fdfind) /usr/local/bin/fd
```
wavefront.zsh handles this alias automatically if `fdfind` exists.

### Linux: Kitty not using GPU
Check with `kitty --debug-gl`. May need proper GPU drivers. Kitty falls back to software rendering gracefully.
