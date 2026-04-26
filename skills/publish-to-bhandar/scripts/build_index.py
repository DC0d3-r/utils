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

INDEX_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght,SOFT,WONK@0,9..144,300..900,0..100,0..1;1,9..144,300..900,0..100,0..1&family=Spectral:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root {{
  --paper:        #ede4d0;
  --paper-warm:   #e3d8bf;
  --paper-dark:   #d9ceb4;
  --paper-edge:   #c4b89d;
  --ink:          #1a1f2e;
  --ink-soft:     #3a4256;
  --ink-fade:     #6c7388;
  --vermilion:    #c8421e;
  --saffron:      #d9941a;
  --verdigris:    #6b8e7f;
  --crimson:      #8b3a3a;
  --gold:         #b08544;
  --gold-deep:    #8a6418;
  --rule:         #c4b89d;
  --rule-faint:   #d4c8ad;
}}

* {{ box-sizing: border-box; margin: 0; padding: 0; }}

html, body {{
  background: var(--paper); color: var(--ink);
  font-family: 'Spectral', Georgia, serif;
  font-weight: 400; font-size: 17px; line-height: 1.65;
  scroll-behavior: smooth; overflow-x: hidden;
}}

::selection {{ background: var(--saffron); color: var(--ink); }}

body::before {{
  content: '';
  position: fixed; inset: 0;
  pointer-events: none; z-index: 100;
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='180' height='180'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='2' stitchTiles='stitch'/><feColorMatrix values='0 0 0 0 0.10 0 0 0 0 0.12 0 0 0 0 0.18 0 0 0 0.18 0'/></filter><rect width='100%25' height='100%25' filter='url(%23n)'/></svg>");
  opacity: 0.35; mix-blend-mode: multiply;
}}

.watermark {{
  position: absolute;
  font-family: 'Fraunces', serif;
  color: var(--ink); opacity: 0.04;
  font-weight: 900;
  pointer-events: none; user-select: none; z-index: 0;
  font-variation-settings: 'opsz' 144, 'SOFT' 100, 'WONK' 1;
}}
.wm-1 {{ top: 4rem;   right: -3rem;  font-size: 18rem; }}
.wm-2 {{ top: 50%;    left: -5rem;   font-size: 22rem; transform: rotate(-12deg); }}
.wm-3 {{ bottom: 8rem; right: 8%;    font-size: 12rem; transform: rotate(8deg); }}

main {{ max-width: 1180px; margin: 0 auto; padding: 5rem 2.25rem 7rem; position: relative; z-index: 1; }}

header {{ text-align: center; margin-bottom: 5.5rem; position: relative; padding-top: 1.25rem; }}

.seal {{
  display: inline-block;
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.72rem; letter-spacing: 0.32em;
  color: var(--vermilion); font-weight: 600;
  margin-bottom: 2.6rem; text-transform: uppercase;
}}
.seal::before, .seal::after {{
  content: '◆'; color: var(--saffron); font-size: 0.85em;
  vertical-align: middle; margin: 0 0.85em; opacity: 0.75;
}}

h1 {{
  font-family: 'Fraunces', serif;
  font-weight: 300;
  font-size: clamp(3.5rem, 11vw, 8.5rem);
  line-height: 0.92; letter-spacing: -0.03em;
  font-variation-settings: 'opsz' 144, 'SOFT' 50, 'WONK' 1;
  color: var(--ink); margin-bottom: 1.6rem;
}}
h1 em {{
  font-style: italic; font-weight: 500; color: var(--vermilion);
  font-variation-settings: 'opsz' 144, 'SOFT' 100, 'WONK' 1;
}}

.devanagari {{
  font-family: 'Fraunces', serif;
  font-weight: 400; font-size: 2.2rem;
  color: var(--saffron);
  margin: 0.3rem 0 1.5rem; letter-spacing: 0.05em;
  font-variation-settings: 'opsz' 144;
}}

.subtitle {{
  font-family: 'Spectral', serif;
  font-style: italic; font-weight: 300;
  font-size: 1.4rem; color: var(--ink-soft);
  max-width: 60ch; margin: 0 auto 2.2rem;
  letter-spacing: 0.005em; line-height: 1.5;
}}

.meta-bar {{
  display: inline-flex; gap: 1.6rem;
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.7rem; color: var(--ink-fade);
  letter-spacing: 0.14em; text-transform: uppercase;
  border-top: 1px solid var(--rule);
  border-bottom: 1px solid var(--rule);
  padding: 0.85rem 1.6rem;
}}
.meta-bar .dot {{ color: var(--saffron); }}

.shelf {{ margin-top: 3.5rem; }}

.shelf-heading {{
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.68rem; letter-spacing: 0.32em;
  text-transform: uppercase; color: var(--gold-deep);
  margin-bottom: 1.6rem;
  display: flex; align-items: center; gap: 1rem;
}}
.shelf-heading::before, .shelf-heading::after {{
  content: ''; flex: 1; height: 1px; background: var(--rule);
}}

.entry {{
  display: grid; grid-template-columns: 88px 1fr; gap: 2rem;
  padding: 2.4rem 1.5rem 2.6rem;
  border-bottom: 1px solid var(--rule-faint);
  text-decoration: none; color: inherit;
  position: relative;
  transition: background 0.22s ease, padding-left 0.22s ease;
}}
.entry:first-child {{ border-top: 1px solid var(--rule); }}
.entry::before {{
  content: ''; position: absolute; left: 0; top: 0; bottom: 0;
  width: 0; background: var(--vermilion); transition: width 0.22s ease;
}}
.entry:hover {{ background: var(--paper-warm); padding-left: 2rem; }}
.entry:hover::before {{ width: 3px; }}
.entry:hover .roman {{ color: var(--vermilion); }}
.entry:hover .e-title {{ color: var(--ink); }}
.entry:hover .marker {{ background: var(--saffron); color: var(--ink); }}

.roman {{
  font-family: 'Fraunces', serif;
  font-style: italic; font-weight: 300;
  font-size: 3.4rem; line-height: 1;
  color: var(--gold); letter-spacing: -0.02em;
  font-variation-settings: 'opsz' 144, 'SOFT' 100, 'WONK' 1;
  text-align: right; padding-top: 0.3rem;
  transition: color 0.22s ease;
}}

.e-body {{ min-width: 0; }}

.e-kicker {{
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.62rem; letter-spacing: 0.26em;
  text-transform: uppercase; color: var(--ink-fade);
  margin-bottom: 0.55rem;
  display: flex; align-items: center; gap: 0.85rem; flex-wrap: wrap;
}}
.marker {{
  display: inline-block;
  padding: 0.2rem 0.6rem;
  background: var(--paper-dark); color: var(--ink-soft);
  font-size: 0.58rem; font-weight: 600; letter-spacing: 0.18em;
  border-radius: 1px;
  transition: background 0.22s ease, color 0.22s ease;
}}
.marker.research  {{ background: rgba(200, 66, 30, 0.12);  color: var(--vermilion); }}
.marker.study     {{ background: rgba(107, 142, 127, 0.18); color: var(--verdigris); }}
.marker.brief     {{ background: rgba(217, 148, 26, 0.16);  color: var(--gold-deep); }}
.marker.companion {{ background: rgba(139, 58, 58, 0.14);  color: var(--crimson); }}
.marker.series    {{ background: rgba(176, 133, 68, 0.20);  color: var(--gold-deep); }}

.e-title {{
  font-family: 'Fraunces', serif;
  font-weight: 400;
  font-size: clamp(1.55rem, 3.2vw, 2.1rem);
  line-height: 1.18; letter-spacing: -0.012em;
  color: var(--ink); margin-bottom: 0.6rem;
  font-variation-settings: 'opsz' 96, 'SOFT' 50, 'WONK' 1;
  transition: color 0.22s ease;
}}
.e-title em {{
  font-style: italic; color: var(--vermilion); font-weight: 500;
  font-variation-settings: 'opsz' 96, 'SOFT' 100, 'WONK' 1;
}}

.e-lede {{
  font-family: 'Spectral', serif;
  font-style: italic; font-weight: 300;
  font-size: 1.08rem; line-height: 1.55;
  color: var(--ink-soft);
  max-width: 65ch; margin-bottom: 0.95rem;
}}

.e-foot {{
  display: flex; flex-wrap: wrap; gap: 1.15rem;
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.66rem; letter-spacing: 0.12em;
  text-transform: uppercase; color: var(--ink-fade);
}}
.e-foot span + span::before {{
  content: '·'; color: var(--saffron);
  margin-right: 1.15rem; margin-left: -0.7rem;
}}
.e-foot .open {{
  color: var(--vermilion); margin-left: auto; font-weight: 600;
}}
.e-foot .open::after {{ content: ' →'; color: var(--saffron); }}

footer {{
  text-align: center; margin-top: 6rem;
  padding-top: 3rem; border-top: 1px solid var(--rule);
  position: relative; z-index: 1;
}}

.aphorism {{
  font-family: 'Fraunces', serif;
  font-style: italic; font-weight: 300;
  font-size: 1.15rem; color: var(--ink-soft);
  max-width: 50ch; margin: 0 auto 0.85rem;
  font-variation-settings: 'opsz' 96, 'SOFT' 80;
}}
.aphorism .sanskrit {{
  font-family: 'Fraunces', serif;
  color: var(--saffron); font-style: normal;
  font-weight: 400; margin-right: 0.4rem;
}}

.colophon {{
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.62rem; letter-spacing: 0.22em;
  text-transform: uppercase; color: var(--ink-fade);
  margin-top: 1.3rem;
}}
.colophon .sep {{ color: var(--saffron); margin: 0 0.6em; }}

.lock-band {{
  display: inline-flex; align-items: center; gap: 0.7rem;
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.7rem; letter-spacing: 0.32em;
  color: var(--crimson); text-transform: uppercase;
  padding: 0.5rem 1rem;
  border: 1px solid var(--crimson);
  background: rgba(139, 58, 58, 0.06);
  margin: 1.5rem auto 2.6rem;
}}
.lock-band .glyph {{ color: var(--crimson); font-size: 1em; }}

@media (max-width: 720px) {{
  main {{ padding: 3.5rem 1.4rem 5rem; }}
  header {{ margin-bottom: 4rem; }}
  h1 {{ font-size: clamp(2.6rem, 13vw, 4.6rem); }}
  .subtitle {{ font-size: 1.15rem; }}
  .meta-bar {{ flex-direction: column; gap: 0.6rem; padding: 0.85rem 1.2rem; align-items: center; }}
  .entry {{ grid-template-columns: 56px 1fr; gap: 1.2rem; padding: 1.9rem 0.4rem 2rem; }}
  .entry:hover {{ padding-left: 1.2rem; }}
  .roman {{ font-size: 2.4rem; padding-top: 0.1rem; }}
  .e-title {{ font-size: 1.4rem; }}
  .e-lede {{ font-size: 1rem; }}
  .e-foot {{ font-size: 0.6rem; gap: 0.85rem; }}
  .e-foot .open {{ margin-left: 0; }}
}}
</style>
</head>
<body>

<main>
  {watermarks_html}

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
    entries_html = render_entries(entries)
    meta_bar_html = render_meta_bar(site["meta_bar"], len(entries))

    # optional fields fall back to defaults — keeps the public manifest minimal
    # while letting the private one (Antaranga) override watermarks, lock-band, etc.
    colophon_html = site.get("colophon_html", DEFAULT_COLOPHON_HTML).format(entry_count=len(entries))

    rendered = INDEX_TEMPLATE.format(
        title=site["title"],
        seal=site["seal"],
        lock_band_html=site.get("lock_band_html", ""),
        h1_html=site["h1_html"],
        devanagari=site["devanagari"],
        subtitle=site["subtitle"],
        meta_bar_html=meta_bar_html,
        shelf_heading=site["shelf_heading"],
        entries_html=entries_html,
        watermarks_html=site.get("watermarks_html", DEFAULT_WATERMARKS_HTML),
        aphorism_html=site.get("aphorism_html", DEFAULT_APHORISM_HTML),
        colophon_html=colophon_html,
    )
    out = site_dir / "index.html"
    out.write_text(rendered)
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
