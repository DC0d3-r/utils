#!/usr/bin/env python3
"""
build_index.py — regenerate <site-dir>/index.html from <site-dir>/.bhandar/manifest.json

The library landing is a function of the manifest. Edit the manifest, run this,
get a fresh index.html. Idempotent.

Used by both the public bhandar (site/) and the tailnet-only Antaranga (site-private/).
The two sites differ in their manifest's `site` block — they share the same template.

Usage:
  build_index.py                              # default: ~/code/homelab/bhandar/site
  build_index.py --site-dir <path>            # any site root with .bhandar/manifest.json
  build_index.py --target private             # shortcut for ~/code/homelab/bhandar/site-private
"""

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

REPO_ROOT = Path.home() / "code/homelab/bhandar"
SITE_DIRS = {
    "public":  REPO_ROOT / "site",
    "private": REPO_ROOT / "site-private",
}
DEFAULT_SITE = SITE_DIRS["public"]

# defaults for optional site-block fields. manifests can override.
DEFAULT_WATERMARKS_HTML = """<span class="watermark wm-1">&#x092C;</span>
  <span class="watermark wm-2">&#x0917;&#x094D;&#x0930;&#x0902;&#x0925;</span>
  <span class="watermark wm-3">&#x092D;</span>"""

DEFAULT_APHORISM_HTML = """<span class="sanskrit">&#x0938;&#x0930;&#x094D;&#x0935;&#x0902; &#x0916;&#x0932;&#x094D;&#x0935;&#x093F;&#x0926;&#x092E;&#x094D; &#x092C;&#x094D;&#x0930;&#x0939;&#x094D;&#x092E;</span>
      All this, indeed, is Brahman &mdash; what is composed, and what composes; what is read, and what reads."""

DEFAULT_COLOPHON_HTML = """Bhandar v1
      <span class="sep">◆</span>
      Set in Fraunces, Spectral &amp; JetBrains Mono
      <span class="sep">◆</span>
      {entry_count} volumes shelved"""

DEFAULT_EMPTY_HTML = """<div class="empty-shelf">The shelves stand empty for now.<span>New volumes are shelved as the loops complete.</span></div>"""

CANONICAL_ASSETS = ("bhandar.css", "catalogue.css", "favicon.svg")


def plain_text(html: str) -> str:
    """Strip tags from a subtitle for use as a meta description."""
    text = re.sub(r"<[^>]+>", "", html)
    text = re.sub(r"\s+", " ", text).strip()
    return text[:160]


def sync_assets(site_dir: Path) -> None:
    """Copy the canonical stylesheets + favicon into <site>/assets/.

    The skill's assets/ directory is the single source of truth; pages
    link /assets/bhandar.css (articles) or /assets/catalogue.css (index).
    """
    src_dir = Path(__file__).resolve().parent.parent / "assets"
    if not src_dir.is_dir():
        print(f"⚠ skill assets dir missing: {src_dir} — skipping asset sync", file=sys.stderr)
        return
    dst_dir = site_dir / "assets"
    dst_dir.mkdir(exist_ok=True)
    for name in CANONICAL_ASSETS:
        f = src_dir / name
        if not f.exists():
            print(f"⚠ canonical asset missing: {f} — skipping", file=sys.stderr)
            continue
        shutil.copyfile(f, dst_dir / name)


INDEX_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<meta name="description" content="{description}">
<link rel="icon" type="image/svg+xml" href="/assets/favicon.svg">
<meta name="theme-color" content="#ede4d0">
<link rel="canonical" href="{canonical_url}">
<meta property="og:type" content="website">
<meta property="og:title" content="{title}">
<meta property="og:description" content="{description}">
<meta property="og:url" content="{canonical_url}">
<meta name="twitter:card" content="summary">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght,SOFT,WONK@0,9..144,300..900,0..100,0..1;1,9..144,300..900,0..100,0..1&family=Spectral:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/assets/catalogue.css">
</head>
<body>

<main>
  <div class="watermark-layer" aria-hidden="true">
    {watermarks_html}
  </div>

  <header>
    <div class="seal">{seal}</div>
    {lock_band_html}
    <h1>{h1_html}</h1>
    <div class="devanagari">{devanagari}</div>
    <p class="subtitle">{subtitle}</p>
    <div class="meta-bar">{meta_bar_html}</div>
  </header>

  <section class="shelf">
    <div class="shelf-heading">{shelf_heading}</div>
{entries_html}
  </section>

  <footer>
    <p class="aphorism">
      {aphorism_html}
    </p>
    <div class="colophon">
      {colophon_html}
    </div>
  </footer>
</main>

</body>
</html>
"""

ENTRY_TEMPLATE = """    <a class="entry" href="{href}">
      <div class="roman">{roman}.</div>
      <div class="e-body">
        <div class="e-kicker">
          <span>{kicker}</span>
          <span class="marker {marker}">{marker_label}</span>
        </div>
        <div class="e-title">{title_html}</div>
        <p class="e-lede">{lede}</p>
        <div class="e-foot">
{foot_spans}
          <span class="open">{open_label}</span>
        </div>
      </div>
    </a>
"""

ROMAN_NUMERALS = ["i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x",
                  "xi", "xii", "xiii", "xiv", "xv", "xvi", "xvii", "xviii", "xix", "xx"]


def render_entries(entries: list[dict]) -> str:
    """Render the catalog rows. Sort by `order` ascending; missing order = end."""
    sorted_entries = sorted(entries, key=lambda e: e.get("order", 999))
    out = []
    for i, e in enumerate(sorted_entries):
        roman = ROMAN_NUMERALS[i] if i < len(ROMAN_NUMERALS) else str(i + 1)
        date = e.get("date", "")
        meta_tokens = [date] + e.get("meta_tokens", [])
        foot_spans = "\n".join(f"          <span>{t}</span>" for t in meta_tokens if t)
        out.append(ENTRY_TEMPLATE.format(
            href=e["href"],
            roman=roman,
            kicker=e["kicker"],
            marker=e["marker"],
            marker_label=e["marker"].capitalize(),
            title_html=e["title_html"],
            lede=e["lede"],
            foot_spans=foot_spans,
            open_label=e.get("open_label", "Read"),
        ))
    return "\n".join(out)


def render_meta_bar(tokens: list[str], entry_count: int) -> str:
    """Render the meta-bar with `{count}` substitution."""
    rendered = [t.format(count=entry_count) for t in tokens]
    parts = []
    for i, t in enumerate(rendered):
        parts.append(f"<span>{t}</span>")
        if i < len(rendered) - 1:
            parts.append('<span class="dot">◆</span>')
    return "\n      ".join(parts)


def build(site_dir: Path) -> Path:
    """Read manifest, regenerate index.html, return its path."""
    manifest_path = site_dir / ".bhandar" / "manifest.json"
    if not manifest_path.exists():
        sys.exit(f"manifest not found at {manifest_path}")
    manifest = json.loads(manifest_path.read_text())
    site = manifest["site"]
    entries = manifest["entries"]
    if entries:
        entries_html = render_entries(entries)
        shelf_heading = site["shelf_heading"]
    else:
        entries_html = site.get("empty_html", DEFAULT_EMPTY_HTML)
        shelf_heading = site.get("shelf_heading_empty", site["shelf_heading"])
    description = site.get("description") or plain_text(site["subtitle"])
    canonical_url = site.get("canonical_url", "")
    meta_bar_html = render_meta_bar(site["meta_bar"], len(entries))

    # optional fields fall back to defaults — keeps the public manifest minimal
    # while letting the private one (Antaranga) override watermarks, lock-band, etc.
    colophon_html = site.get("colophon_html", DEFAULT_COLOPHON_HTML).format(entry_count=len(entries))

    rendered = INDEX_TEMPLATE.format(
        title=site["title"],
        description=description,
        canonical_url=canonical_url,
        seal=site["seal"],
        lock_band_html=site.get("lock_band_html", ""),
        h1_html=site["h1_html"],
        devanagari=site["devanagari"],
        subtitle=site["subtitle"],
        meta_bar_html=meta_bar_html,
        shelf_heading=shelf_heading,
        entries_html=entries_html,
        watermarks_html=site.get("watermarks_html", DEFAULT_WATERMARKS_HTML),
        aphorism_html=site.get("aphorism_html", DEFAULT_APHORISM_HTML),
        colophon_html=colophon_html,
    )
    out = site_dir / "index.html"
    out.write_text(rendered)
    sync_assets(site_dir)
    return out


def resolve_site_dir(site_dir_arg, target_arg) -> Path:
    """--site-dir takes precedence; otherwise --target picks public/private."""
    if site_dir_arg is not None:
        return site_dir_arg
    if target_arg is not None:
        return SITE_DIRS[target_arg]
    return DEFAULT_SITE


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--site-dir", type=Path, default=None,
                   help="any directory containing .bhandar/manifest.json")
    p.add_argument("--target", choices=list(SITE_DIRS.keys()), default=None,
                   help="shortcut: 'public' (the bhandar) or 'private' (the Antaranga)")
    args = p.parse_args()
    site_dir = resolve_site_dir(args.site_dir, args.target)
    out = build(site_dir)
    manifest = json.loads((site_dir / ".bhandar" / "manifest.json").read_text())
    print(f"✓ {out}  ({len(manifest['entries'])} entries)")


if __name__ == "__main__":
    main()
