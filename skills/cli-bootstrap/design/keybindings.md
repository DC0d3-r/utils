# Wavefront: Keybinding Philosophy

## Modifier Convention

| Modifier       | Role                                     |
|----------------|------------------------------------------|
| Ctrl           | Primary actions (new, close, navigate)   |
| Ctrl+Shift     | Secondary, destructive, or config actions|
| Alt            | Reserved for shell/readline defaults     |

## Tab Management

| Intent              | Binding       |
|---------------------|---------------|
| New tab             | Ctrl+T        |
| Close tab           | Ctrl+W        |
| Rename tab          | Ctrl+Shift+R  |
| Jump to tab 1-5     | Ctrl+1 .. 5   |
| Next tab            | Ctrl+Tab      |
| Previous tab        | Ctrl+Shift+Tab|

## Split Management

| Intent              | Binding       |
|---------------------|---------------|
| Split right         | Ctrl+D        |
| Split down          | Ctrl+Shift+D  |
| Close split         | Ctrl+W        |
| Cycle splits        | Ctrl+\[       |
| Zoom (toggle)       | Ctrl+Shift+Z  |
| Equalize splits     | Ctrl+Shift+E  |
| Resize (directional)| Ctrl+Shift+Arrows |

## Font Size

| Intent              | Binding       |
|---------------------|---------------|
| Increase            | Ctrl+=        |
| Decrease            | Ctrl+-        |
| Reset               | Ctrl+0        |

## Utility

| Intent              | Binding       |
|---------------------|---------------|
| Toggle transparency | Ctrl+Shift+T  |
| Fullscreen          | F11           |
| Reload config       | Ctrl+Shift+F5 |
| Open scrollback     | Ctrl+Shift+H  |

## Shell Conflicts

Several of these bindings collide with shell/readline defaults:

| Binding | Shell default      | Resolution                              |
|---------|--------------------|-----------------------------------------|
| Ctrl+D  | Send EOF (logout)  | Terminal intercepts before shell         |
| Ctrl+W  | Delete word back   | Terminal intercepts before shell         |
| Ctrl+\[ | Escape equivalent  | Terminal intercepts before shell         |

The terminal must capture these bindings at the terminal level so they never reach the shell. This means the shell loses those shortcuts. In practice:

- **Ctrl+D (EOF):** Type `exit` instead, or use Ctrl+Shift+W for an explicit close
- **Ctrl+W (delete word):** Use Alt+Backspace (readline default equivalent)
- **Ctrl+\[ (escape):** Use the actual Escape key

These tradeoffs are worth it. Tab and split management are used constantly; the shell alternatives are adequate.

## Principles

- **Muscle memory over logic.** Prefer bindings that match common GUI conventions (Ctrl+T for new tab, Ctrl+W for close) even when they conflict with terminal tradition.
- **Discoverable grouping.** Related actions share a modifier pattern. All split operations use the same base modifier.
- **Don't rebind everything.** Only bind what you use. An unmapped key is better than a binding you forget exists.
