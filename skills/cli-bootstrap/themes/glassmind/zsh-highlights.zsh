# Theme: Glassmind — ZSH syntax highlighting
# Source this in your .zshrc after loading zsh-syntax-highlighting.

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#353548"

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#D8D4EA'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#E07070'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#A080C0'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#70C090'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#70C090'
ZSH_HIGHLIGHT_STYLES[function]='fg=#70C090'
ZSH_HIGHLIGHT_STYLES[command]='fg=#70C090'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#70C090,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#A080C0'
ZSH_HIGHLIGHT_STYLES[path]='fg=#7090D0,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#D0B878'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#70B8B0'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#70B8B0'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#70B8B0'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#A080C0'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#D0B878'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#D0B878'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#7A7A8C,italic'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#70C090'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#9090A0'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#9090A0'
