# Theme: Rose Pine — ZSH syntax highlighting
# Source this in your .zshrc after loading zsh-syntax-highlighting.

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#403D52"

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#E0DEF4'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#EB6F92'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#C4A7E7'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#31748F'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#31748F'
ZSH_HIGHLIGHT_STYLES[function]='fg=#31748F'
ZSH_HIGHLIGHT_STYLES[command]='fg=#31748F'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#31748F,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#C4A7E7'
ZSH_HIGHLIGHT_STYLES[path]='fg=#9CCFD8,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#F6C177'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#EBBCBA'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#EBBCBA'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#EBBCBA'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#C4A7E7'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#F6C177'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#F6C177'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#555169,italic'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#31748F'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#6E6A86'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#6E6A86'
