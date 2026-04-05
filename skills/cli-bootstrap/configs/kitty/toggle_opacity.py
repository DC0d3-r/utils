# Wavefront — Toggle between zen mode (solid) and show-off mode (glass)
# Triggered by Ctrl+Shift+O
#
# Two states:
#   1.0  (solid, daily driver — the default)
#   0.88 (glass, show-off — enough transparency for wallpaper, contrast preserved)
#
# WARNING: Glass mode is designed for DARK wallpapers only.
# Light/bright desktop backgrounds will reduce comment readability below WCAG AA
# because Ash (#727169, 4.6:1 on Sumi) loses contrast when the effective
# background lightens. Pair with wavefront-wallpaper.png for guaranteed results.

def main(args):
    pass

def handle_result(args, answer, target_window_id, boss):
    import kitty.fast_data_types as f
    os_window_id = f.current_focused_os_window_id()
    current = f.background_opacity_of(os_window_id)

    if current >= 0.95:
        # Currently solid -> switch to glass
        boss.set_background_opacity("0.88")
    else:
        # Currently glass -> switch to solid
        boss.set_background_opacity("1.0")
