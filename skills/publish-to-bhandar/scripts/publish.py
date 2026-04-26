#!/usr/bin/env python3
"""
publish.py — register a new entry in the bhandar and rebuild the index.

This script does NOT generate the page HTML — Claude does that, using
the assets/page-template.html and the design-system reference. This script
handles the mechanical bits: validate metadata, append/update the manifest,
rebuild the catalogue index, optionally git-commit + push.

Workflow (typical):
  1. Claude writes site/<slug>.html (or site/<slug>/index.html) using
     assets/page-template.html as the wrapper + brahma-aesthetic typography.
  2. `publish.py register --metadata '<json>'`  — adds entry to manifest.
  3. (auto) `build_index.py`  — regenerates site/index.html from the manifest.
  4. `publish.py commit` — git add + commit + push.

Or, the full pipeline in one shot:
  publish.py register --metadata '<json>' --commit

Metadata JSON (one entry):
  {
    "slug":        "indrajaal",                   # filename stem (or dirname for series)
    "href":        "/indrajaal.html",             # url path the catalog links to
    "title_html":  "The Net of <em>Indrajaal</em>",
    "kicker":      "User-flow Study",
    "lede":        "One coherent assistant from four narrow agents...",
    "marker":      "study",                       # research|study|brief|companion|series
    "date":        "2026-04-26",
    "meta_tokens": ["Four Hermes profiles", "~14 min"],
    "open_label":  "Read",                        # button text — Read / Open / Open Volume I
    "order":       20                             # sort key, lower = higher in catalog
  }

Order convention: leave existing entries' `order` alone, give a new entry an
order that places it where you want. Typically:
  - 5  for a brand-new flagship piece (top of catalog)
  - 15 to slot between existing 10 and 20
  - 999 to send to the bottom

Files this touches:
  ~/code/homelab/bhandar/site/.bhandar/manifest.json     (read+write)
  ~/code/homelab/bhandar/site/index.html                 (rewrite from manifest)
  ~/code/homelab/bhandar/                                (git add + commit + push)
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

# import the index builder living next to us
sys.path.insert(0, str(Path(__file__).parent))
from build_index import build as build_index_html

DEFAULT_REPO = Path.home() / "code/homelab/bhandar"

REQUIRED_FIELDS = {"slug", "href", "title_html", "kicker", "lede", "marker", "date"}
VALID_MARKERS = {"research", "study", "brief", "companion", "series"}


def load_manifest(site_dir: Path) -> dict:
    p = site_dir / ".bhandar" / "manifest.json"
    if not p.exists():
        sys.exit(f"manifest missing: {p}")
    return json.loads(p.read_text())


def save_manifest(site_dir: Path, manifest: dict) -> None:
    p = site_dir / ".bhandar" / "manifest.json"
    p.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")


def validate(entry: dict) -> None:
    missing = REQUIRED_FIELDS - entry.keys()
    if missing:
        sys.exit(f"entry missing required fields: {sorted(missing)}")
    if entry["marker"] not in VALID_MARKERS:
        sys.exit(f"marker must be one of {sorted(VALID_MARKERS)} (got {entry['marker']!r})")
    entry.setdefault("meta_tokens", [])
    entry.setdefault("open_label", "Read")
    entry.setdefault("order", 999)


def cmd_register(args):
    site = args.repo / "site"
    entry = json.loads(args.metadata)
    validate(entry)

    manifest = load_manifest(site)
    # remove any existing entry with the same slug (upsert)
    before = len(manifest["entries"])
    manifest["entries"] = [e for e in manifest["entries"] if e["slug"] != entry["slug"]]
    replaced = before > len(manifest["entries"])
    manifest["entries"].append(entry)
    save_manifest(site, manifest)

    out = build_index_html(site)
    action = "Replaced" if replaced else "Added"
    print(f"✓ {action} entry {entry['slug']!r}")
    print(f"✓ Rebuilt {out.relative_to(args.repo)}")

    # confirm the page file actually exists where the entry says it lives
    page_path = site / entry["href"].lstrip("/")
    if entry["href"].endswith("/"):
        page_path = page_path / "index.html"
    if not page_path.exists():
        print(f"⚠ entry href points to {page_path} but the file does not exist yet — write it before committing", file=sys.stderr)

    if args.commit:
        cmd_commit_with_repo(args.repo, message=f"publish: {entry['slug']}", push=not args.no_push)


def cmd_remove(args):
    site = args.repo / "site"
    manifest = load_manifest(site)
    before = len(manifest["entries"])
    manifest["entries"] = [e for e in manifest["entries"] if e["slug"] != args.slug]
    if len(manifest["entries"]) == before:
        sys.exit(f"no entry with slug {args.slug!r}")
    save_manifest(site, manifest)
    out = build_index_html(site)
    print(f"✓ Removed {args.slug!r} from catalogue")
    print(f"✓ Rebuilt {out.relative_to(args.repo)}")
    print(f"  (the page file is NOT deleted — remove it manually if you want)")


def cmd_rebuild(args):
    out = build_index_html(args.repo / "site")
    manifest = load_manifest(args.repo / "site")
    print(f"✓ Rebuilt {out.relative_to(args.repo)}  ({len(manifest['entries'])} entries)")


def cmd_commit_with_repo(repo: Path, message: str, push: bool = True):
    subprocess.run(["git", "add", "-A"], cwd=repo, check=True)
    # check if there's anything to commit
    diff = subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=repo)
    if diff.returncode == 0:
        print("✓ Nothing to commit (working tree matches HEAD)")
        return
    subprocess.run(
        ["git", "-c", "commit.gpgsign=false", "commit", "-m", message],
        cwd=repo, check=True,
    )
    print(f"✓ Committed: {message}")
    if push:
        subprocess.run(["git", "push"], cwd=repo, check=True)
        print(f"✓ Pushed")


def cmd_commit(args):
    cmd_commit_with_repo(args.repo, message=args.message, push=not args.no_push)


def cmd_list(args):
    manifest = load_manifest(args.repo / "site")
    entries = sorted(manifest["entries"], key=lambda e: e.get("order", 999))
    for e in entries:
        print(f"  [{e.get('order', '???'):>3}] {e['marker']:<10} {e['slug']:<28} {e['date']:<11} {e['href']}")
    print(f"\n{len(entries)} entries.")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--repo", type=Path, default=DEFAULT_REPO,
                   help="bhandar repo root (default: ~/code/homelab/bhandar)")
    sub = p.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("register", help="add or update an entry, then rebuild the index")
    sp.add_argument("--metadata", required=True, help="JSON metadata for one entry (see module docstring)")
    sp.add_argument("--commit", action="store_true", help="git add + commit + push after registering")
    sp.add_argument("--no-push", action="store_true", help="commit but don't push (only with --commit)")
    sp.set_defaults(func=cmd_register)

    sp = sub.add_parser("remove", help="remove an entry by slug; does NOT delete the page file")
    sp.add_argument("slug")
    sp.set_defaults(func=cmd_remove)

    sp = sub.add_parser("rebuild", help="regenerate index.html from manifest (no metadata change)")
    sp.set_defaults(func=cmd_rebuild)

    sp = sub.add_parser("commit", help="git add + commit + push the bhandar repo")
    sp.add_argument("-m", "--message", required=True)
    sp.add_argument("--no-push", action="store_true")
    sp.set_defaults(func=cmd_commit)

    sp = sub.add_parser("list", help="show the catalogue")
    sp.set_defaults(func=cmd_list)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
