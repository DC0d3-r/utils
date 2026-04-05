#!/usr/bin/env bash
# Generate a subtle paper-grain noise texture for Kitty background.
# Requires ImageMagick (convert/magick command).
#
# The texture tiles seamlessly at 0.5 tint in kitty.conf, adding
# perceived depth to the solid sumi (#1F1F28) background — like
# washi paper under the ink.
#
# Usage: ./generate-noise.sh [output_dir]
#   Default output: ~/Pictures/kitty-backgrounds/wavefront-noise.png

set -euo pipefail

OUTPUT_DIR="${1:-$HOME/Pictures/kitty-backgrounds}"
OUTPUT_FILE="$OUTPUT_DIR/wavefront-noise.png"

# Check for ImageMagick
if command -v magick &>/dev/null; then
    CONVERT="magick"
elif command -v convert &>/dev/null; then
    CONVERT="convert"
else
    echo "Error: ImageMagick not found. Install with:"
    echo "  macOS:  brew install imagemagick"
    echo "  Linux:  sudo apt install imagemagick"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Generate 256x256 monochrome gaussian noise, tileable.
# - Monochrome so it doesn't introduce color cast
# - Small size because kitty tiles it (repeats)
# - Low intensity so it's subtle at 0.5 tint
$CONVERT -size 256x256 \
    xc: +noise Gaussian \
    -colorspace Gray \
    -modulate 100,0 \
    -blur 0x0.5 \
    -normalize \
    "$OUTPUT_FILE"

echo "Generated: $OUTPUT_FILE"
echo "Add to kitty.conf:"
echo "  background_image       $OUTPUT_FILE"
echo "  background_image_layout tiled"
echo "  background_tint        0.5"
