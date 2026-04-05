# Wavefront Tab Bar — Optional informational upgrade
# Save to: ~/.config/kitty/tab_bar.py
# To enable: change tab_bar_style to "custom" in kitty.conf

import datetime
from kitty.fast_data_types import Screen
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_title,
)

# Wavefront surface colors
VOID       = as_rgb(0x111117)   # deepest layer — bar background
INK        = as_rgb(0x16161D)   # inactive tab bg
SUMI       = as_rgb(0x1F1F28)   # active tab bg (matches terminal bg)
STONE      = as_rgb(0x2A2A37)   # separator color
IVORY_FG   = as_rgb(0xDCD7BA)   # active text
ASH_FG     = as_rgb(0x727169)   # inactive text
GOLD       = as_rgb(0xC4B28A)   # accent: active indicator
BLUE       = as_rgb(0x7E9CD8)   # accent: clock/info

SOFT_SEP   = " "


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw a single tab in Wavefront style — quiet, warm, minimal."""

    # Separator
    screen.cursor.bg = VOID
    screen.cursor.fg = STONE
    screen.draw(SOFT_SEP)

    # Tab body
    if tab.is_active:
        # Active tab: sumi background (matches terminal), ivory text
        screen.cursor.bg = SUMI
        screen.cursor.fg = GOLD
        screen.draw(" |")   # subtle gold bar as active indicator
        screen.cursor.fg = IVORY_FG
    else:
        # Inactive tab: ink background, ash text
        screen.cursor.bg = INK
        screen.cursor.fg = ASH_FG
        screen.draw("  ")

    # Tab title
    title = tab.title
    max_title = max_tab_length - 5
    if len(title) > max_title:
        title = title[: max_title - 1] + "..."
    screen.draw(f" {title} ")

    # Right status zone (last tab only)
    if is_last:
        screen.cursor.bg = VOID
        screen.cursor.fg = ASH_FG

        now = datetime.datetime.now().strftime("%H:%M")
        right_status = f"  {now}  "
        cells_remaining = screen.columns - screen.cursor.x - len(right_status)

        if cells_remaining > 0:
            screen.draw(" " * cells_remaining)

        screen.cursor.fg = BLUE
        screen.draw(right_status)

    return screen.cursor.x
