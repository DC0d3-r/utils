#!/usr/bin/env zsh
# ==============================================================================
#  Wavefront ZSH Configuration — v1.0-final
#  Source this from your .zshrc:  source ~/.config/wavefront/wavefront.zsh
#
#  This file contains all Wavefront-specific shell customizations:
#  - Syntax highlighting colors
#  - FZF theme
#  - Tool aliases (eza, bat, ripgrep, fd)
#  - Helper functions
#  - Greeter image
#  - Starship prompt + transient prompt
#
#  Your .zshrc keeps its own PATH, NVM, history, completions, etc.
# ==============================================================================

# ─── Guard: don't double-source ──────────────────────────────────────────────
[[ -n "$WAVEFRONT_LOADED" ]] && return
export WAVEFRONT_LOADED=1

# ─── Resolve script directory (for relative paths) ──────────────────────────
WAVEFRONT_DIR="${0:A:h}"

# ─── Plugins (platform-aware paths) ─────────────────────────────────────────
# Try Homebrew paths first (macOS), then common Linux paths, then ~/.zsh/
_wf_try_source() {
    for path in "$@"; do
        [[ -f "$path" ]] && source "$path" && return 0
    done
    return 1
}

_wf_try_source \
    /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

_wf_try_source \
    /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ─── Wavefront — Plugin Colors ──────────────────────────────────────────────
# Autosuggestions: whisper in Drift — visible enough to read, dim enough to ignore
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#44445B"

# Syntax highlighting: warm, muted — commands in moss green, errors in autumn red
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#DCD7BA'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#D0605A'           # errors — autumnLeaf
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#957FB8'            # keywords — oniViolet
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7BA888'                    # valid commands — mossGreen
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7BA888'
ZSH_HIGHLIGHT_STYLES[function]='fg=#7BA888'
ZSH_HIGHLIGHT_STYLES[command]='fg=#7BA888'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#7BA888,underline'     # sudo, env
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#957FB8'         # ; && ||
ZSH_HIGHLIGHT_STYLES[path]='fg=#7E9CD8,underline'           # paths — crystalBlue
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#C4B28A'                 # globs — sandGold
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#6DB5A8'   # strings — waveAqua
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#6DB5A8'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#6DB5A8'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#957FB8'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#C4B28A'                   # var=val — sandGold
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#C4B28A'              # > >> |
ZSH_HIGHLIGHT_STYLES[comment]='fg=#727169,italic'           # comments — ash
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#7BA888'                     # first word
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#938E7E'     # -f — clay
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#938E7E'     # --flag — clay

# ─── FZF ─────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
    # Source fzf keybindings (Ctrl-R, Ctrl-T, Alt-C)
    [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    # Modern fzf (0.48+) uses --zsh
    command -v fzf &>/dev/null && eval "$(fzf --zsh 2>/dev/null)" || true

    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS="
      --height 50%
      --color=bg+:#2A2A37,bg:#1F1F28,spinner:#6DB5A8,hl:#957FB8
      --color=fg:#DCD7BA,header:#7E9CD8,info:#C4B28A,pointer:#7E9CD8
      --color=marker:#7BA888,fg+:#EDEAD5,prompt:#7E9CD8,hl+:#B09FD6
      --color=selected-bg:#363646
      --color=border:#44445B,label:#938E7E,query:#DCD7BA
      --border=rounded
      --prompt='> '
      --pointer='>'
      --marker='+'
      --separator='─'
      --info=inline
      --preview 'bat --color=always --style=numbers --line-range=:100 {}'
      --preview-window right:50%:wrap
    "
    export FZF_ALT_C_OPTS='--preview "eza --tree --color=always {} | head -50"'
fi

# ─── Zoxide ───────────────────────────────────────────────────────────────���──
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ─── ALIASES — navigation ────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ─── ALIASES — ls → eza ────────────────────────────────��─────────────────────
if command -v eza &>/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza --icons=auto --group-directories-first -la --no-permissions --no-user --time-style=relative'
    alias lt='eza --icons=auto --group-directories-first --tree --level=2'
    alias llt='eza --icons=auto --group-directories-first --tree --level=3 -la'
fi

# ─── ALIASES — cat → bat ────────────────────────────���────────────────────────
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'
fi

# ─── ALIASES — grep → ripgrep ────────────────────────────────────────────────
command -v rg &>/dev/null && alias grep='rg'

# ─── ALIASES — find → fd ─────────────────────────────────────────────────────
command -v fd &>/dev/null && alias find='fd'

# ─── ALIASES — git ───────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ─── ALIASES — misc ──────────────────────────────────────────────────────────
alias reload='source ~/.zshrc'
alias zshrc='${EDITOR:-nano} ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
alias df='df -h'
alias du='du -sh'
alias cls='clear'

# ─── ALIASES — SSH TERM fix ──────────────────────────────────────────────────
alias ssh='TERM=xterm-256color ssh'

# ─── FUNCTIONS ────────────────────────────────────────────────────────────────
# Create dir and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# Quick find in current directory
ff() { fd --type f --hidden "$1" }

# Fuzzy-jump to a directory (uses zoxide + fzf)
fcd() {
    local dir
    dir=$(zoxide query --list | fzf --height 40% --border) && cd "$dir"
}

# Preview files with bat via fzf
fv() {
    fzf --preview 'bat --color=always --style=numbers {}' | xargs -r ${EDITOR:-nano}
}

# Extract any archive
extract() {
    case "$1" in
        *.tar.gz|*.tgz)   tar xzf "$1"  ;;
        *.tar.bz2|*.tbz2) tar xjf "$1"  ;;
        *.tar.xz)         tar xJf "$1"  ;;
        *.tar)            tar xf  "$1"  ;;
        *.zip)            unzip   "$1"  ;;
        *.gz)             gunzip  "$1"  ;;
        *.bz2)            bunzip2 "$1"  ;;
        *.xz)             unxz    "$1"  ;;
        *.7z)             7z x    "$1"  ;;
        *) echo "Unknown archive format: $1" ;;
    esac
}

# ─── Wavefront — Tool Themes ────────────────────────────────────────────────
export BAT_THEME="ansi"
export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=33;1:cd=33:su=31;1:sg=31:tw=34;1:ow=34;1:*.md=36:*.json=33:*.yml=33:*.yaml=33:*.toml=33:*.ts=34:*.js=33:*.py=33:*.rs=31:*.go=34:*.sh=32:*.zsh=32"
export EZA_COLORS="da=38;5;102:uu=38;5;102:gu=38;5;102:sn=38;5;137:sb=38;5;137:ur=33:uw=31:ux=32:ue=32:gr=33:gw=31:gx=32:tr=33:tw=31:tx=32"

# ─── Wavefront — Man page colors (LESS_TERMCAP) ─────────────────────────────
export LESS_TERMCAP_mb=$'\e[1;31m'    # begin blink
export LESS_TERMCAP_md=$'\e[1;34m'    # begin bold (crystalBlue headers)
export LESS_TERMCAP_me=$'\e[0m'       # end bold/blink
export LESS_TERMCAP_so=$'\e[33m'      # standout (sandGold status bar)
export LESS_TERMCAP_se=$'\e[0m'       # standout end
export LESS_TERMCAP_us=$'\e[4;36m'    # underline start (waveAqua arguments)
export LESS_TERMCAP_ue=$'\e[0m'       # underline end

# ─── GREETER ─────────────────────────────────────────────────────────────────
# Display artwork on interactive shell startup (skip in VSCode, Emacs, non-Kitty)
if [[ -z "$VSCODE_RESOLVING_ENVIRONMENT" && -z "$INSIDE_EMACS" && -o interactive && -z "$GREETER_SHOWN" ]]; then
    export GREETER_SHOWN=1
    # Only show in kitty (kitten icat requires kitty terminal protocol)
    if [[ -n "$KITTY_PID" ]]; then
        local greeter_img="$HOME/.config/wavefront/greeter/enso-koi.jpg"
        [[ -f "$greeter_img" ]] && kitten icat --align center "$greeter_img"
    fi
fi

# ─── STARSHIP PROMPT ────────────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ─── Wavefront — Transient Prompt ─────────────────────────────��─────────────
# After command execution, collapse the full prompt to just ">".
# crystalBlue (#7E9CD8) = RGB 126, 156, 216
# Must be AFTER starship init.
export STARSHIP_TRANSIENT_PROMPT_COMMAND='echo -ne "\e[38;2;126;156;216m>\e[0m "'

# ─── Window title: just the directory name ───────────────────────────────��──
function _wavefront_set_title() {
    echo -ne "\033]0;$(basename "$PWD")\007"
}
precmd_functions+=(_wavefront_set_title)

# ─── Suppress login message ───────────────────────────────────────────────��─
[[ ! -f "$HOME/.hushlogin" ]] && touch "$HOME/.hushlogin"
