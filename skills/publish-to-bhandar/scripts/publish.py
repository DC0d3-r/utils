#!/usr/bin/env python3
"""
publish.py — register a new entry in the bhandar and rebuild the index.

This script does NOT generate the page HTML — Claude does that, using
the assets/page-template.html and the design-system reference. This script
handles the mechanical bits: validate metadata, append/update the manifest,
rebuild the catalogue index, optionally git-commit + push.

The bhandar has TWO sides — pick which one with --target:
  --target public   (default)  → ~/code/homelab/bhandar/site/        public, funnel'd
  --target private              → ~/code/homelab/bhandar/site-private/  tailnet-only Antaranga

The private side is gitignored — `--commit` only touches public repo state.
For private entries you commit nothing; the file is served as soon as it lands.

Workflow (typical, public):
  1. Claude writes site/<slug>.html using assets/page-template.html.
  2. `publish.py register --metadata '<json>'` adds entry to manifest, rebuilds index.
  3. `publish.py register ... --commit` does it and git-pushes the public repo.

Workflow (private, Antaranga):
  1. Claude writes site-private/<slug>.html.
  2. `publish.py register --target private --metadata '<json>'` adds + rebuilds.
  3. (No commit — site-private/ is gitignored. Caddy serves it instantly via the live mount.)

Metadata JSON (one entry):
  {
    "slug":        "indrajaal",                   # filename stem (or dirname for series)
    "description": "One-sentence summary — REQUIRED. Feeds the meta
                    description + Open Graph tags on the page itself.",
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

Files this touches (depending on --target):
  PUBLIC:   site/.bhandar/manifest.json + site/index.html (+ git commit/push if --commit)
  PRIVATE:  site-private/.bhandar/manifest.json + site-private/index.html (no git — gitignored)
"""

import argparse
import json
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path

# import the index builder living next to us
sys.path.insert(0, str(Path(__file__).parent))
from build_index import build as build_index_html, SITE_DIRS

DEFAULT_REPO = Path.home() / "code/homelab/bhandar"

REQUIRED_FIELDS = {"slug", "href", "title_html", "kicker", "lede", "marker", "date", "description"}
VALID_MARKERS = {"research", "study", "brief", "companion", "series"}


PAGE_WARN_BYTES = 100_000    # per-page weight budget (warning)
PAGE_FAIL_BYTES = 500_000    # per-page hard limit (register/check fail)
DOCROOT_WARN_BYTES = 100 * 1024 * 1024


class PageAudit(HTMLParser):
    """Collect the facts the publishing guardrails check."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.lang = None
        self.title = ""
        self._in_title = False
        self.meta_description = None
        self.ids = []
        self.links = []
        self._a_depth = 0
        self.nested_anchor = False

    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag == "html":
            self.lang = d.get("lang")
        elif tag == "title":
            self._in_title = True
        elif tag == "meta" and d.get("name") == "description":
            self.meta_description = d.get("content", "")
        elif tag == "a":
            if self._a_depth > 0:
                self.nested_anchor = True
            self._a_depth += 1
            if d.get("href"):
                self.links.append(d["href"])
        elif tag in ("img", "audio", "video", "source"):
            if d.get("src"):
                self.links.append(d["src"])
        elif tag == "link" and d.get("href"):
            self.links.append(d["href"])
        if d.get("id"):
            self.ids.append(d["id"])

    def handle_endtag(self, tag):
        if tag == "title":
            self._in_title = False
        elif tag == "a" and self._a_depth > 0:
            self._a_depth -= 1

    def handle_data(self, data):
        if self._in_title:
            self.title += data


def page_path_for(site: Path, href: str) -> Path:
    p = site / href.lstrip("/")
    if href.endswith("/"):
        p = p / "index.html"
    return p


def audit_page(site: Path, entry: dict):
    """Return (problems, warnings) for one manifest entry's page."""
    problems, warnings = [], []
    page = page_path_for(site, entry["href"])
    if not page.exists():
        return [f"{entry['slug']}: page file does not exist: {page}"], warnings
    text = page.read_text(errors="replace")
    size = page.stat().st_size
    if size > PAGE_FAIL_BYTES:
        problems.append(f"{entry['slug']}: page is {size:,} bytes (hard limit {PAGE_FAIL_BYTES:,})")
    elif size > PAGE_WARN_BYTES:
        warnings.append(f"{entry['slug']}: page is {size:,} bytes (budget {PAGE_WARN_BYTES:,})")
    if "<script" in text.lower():
        problems.append(f"{entry['slug']}: page contains a <script> tag — the Bhandar is zero-JS")
    if "{{" in text:
        problems.append(f"{entry['slug']}: page still contains unfilled template placeholders")
    audit = PageAudit()
    try:
        audit.feed(text)
    except Exception as exc:
        problems.append(f"{entry['slug']}: HTML parse failed: {exc}")
        return problems, warnings
    if not audit.lang:
        problems.append(f"{entry['slug']}: <html> has no lang attribute")
    if not audit.title.strip():
        problems.append(f"{entry['slug']}: missing or empty <title>")
    desc = audit.meta_description
    if desc is None or not desc.strip():
        problems.append(f"{entry['slug']}: missing or empty meta description")
    elif entry.get("description") and desc.strip() != entry["description"].strip():
        problems.append(f"{entry['slug']}: meta description does not match the manifest description")
    if audit.nested_anchor:
        problems.append(f"{entry['slug']}: nested <a> elements found")
    dupes = sorted({i for i in audit.ids if audit.ids.count(i) > 1})
    if dupes:
        problems.append(f"{entry['slug']}: duplicate id attributes: {dupes}")
    return problems, warnings


def resolve_link(site: Path, base_file: Path, raw: str):
    """Resolve an internal link to a filesystem path; None if external/anchor."""
    if not raw or raw.startswith(("#", "http://", "https://", "mailto:", "data:", "tel:")):
        return None
    path_part = raw.split("#", 1)[0].split("?", 1)[0]
    if not path_part:
        return None
    if path_part.startswith("/"):
        target = site / path_part.lstrip("/")
    else:
        target = base_file.parent / path_part
    if path_part.endswith("/") or target.is_dir():
        target = target / "index.html"
    return target


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


def site_for(args) -> Path:
    """Resolve which site directory to operate on based on --target."""
    return SITE_DIRS[args.target]


def cmd_register(args):
    site = site_for(args)
    entry = json.loads(args.metadata)
    validate(entry)

    # guardrail: the page must exist and pass audit BEFORE the manifest is
    # touched, so a refused publish leaves the catalogue exactly as it was.
    if args.allow_missing:
        print("⚠ --allow-missing: skipping page checks; the catalogue may link to a page that is not ready", file=sys.stderr)
    else:
        problems, warnings_ = audit_page(site, entry)
        for w in warnings_:
            print(f"⚠ {w}")
        if problems:
            for pr in problems:
                print(f"✗ {pr}", file=sys.stderr)
            sys.exit("register refused — fix the page first (or pass --allow-missing to register metadata only)")

    manifest = load_manifest(site)
    # remove any existing entry with the same slug (upsert)
    before = len(manifest["entries"])
    manifest["entries"] = [e for e in manifest["entries"] if e["slug"] != entry["slug"]]
    replaced = before > len(manifest["entries"])
    manifest["entries"].append(entry)
    save_manifest(site, manifest)

    out = build_index_html(site)
    action = "Replaced" if replaced else "Added"
    print(f"✓ {action} {args.target} entry {entry['slug']!r}")
    print(f"✓ Rebuilt {out.relative_to(args.repo)}")


    if args.commit:
        if args.target == "private":
            print("ℹ skipping commit — site-private/ is gitignored. Caddy serves the new page immediately via the live mount.")
        else:
            cmd_commit_with_repo(args.repo, message=f"publish: {entry['slug']}", push=not args.no_push)


def cmd_remove(args):
    site = site_for(args)
    manifest = load_manifest(site)
    before = len(manifest["entries"])
    manifest["entries"] = [e for e in manifest["entries"] if e["slug"] != args.slug]
    if len(manifest["entries"]) == before:
        sys.exit(f"no {args.target} entry with slug {args.slug!r}")
    save_manifest(site, manifest)
    out = build_index_html(site)
    print(f"✓ Removed {args.slug!r} from {args.target} catalogue")
    print(f"✓ Rebuilt {out.relative_to(args.repo)}")
    print(f"  (the page file is NOT deleted — remove it manually if you want)")


def cmd_rebuild(args):
    site = site_for(args)
    out = build_index_html(site)
    manifest = load_manifest(site)
    print(f"✓ Rebuilt {out.relative_to(args.repo)}  ({len(manifest['entries'])} {args.target} entries)")


def cmd_check(args):
    """Audit a whole side: every entry page, every internal link, orphans, weight."""
    site = site_for(args)
    manifest = load_manifest(site)
    problems, warnings = [], []
    queue = []
    for entry in manifest["entries"]:
        probs, warns = audit_page(site, entry)
        problems += probs
        warnings += warns
        page = page_path_for(site, entry["href"])
        if page.exists():
            queue.append(page)
    index = site / "index.html"
    if index.exists():
        queue.append(index)
    # crawl from the catalogue outward so series chapters reached only
    # through other chapters still count as referenced
    seen = set()
    while queue:
        page = queue.pop()
        rp = page.resolve()
        if rp in seen:
            continue
        seen.add(rp)
        audit = PageAudit()
        audit.feed(page.read_text(errors="replace"))
        for raw in audit.links:
            target = resolve_link(site, page, raw)
            if target is None:
                continue
            if not target.exists():
                problems.append(f"{page.relative_to(site)}: broken internal link {raw!r}")
            elif target.suffix == ".html" and target.resolve() not in seen:
                queue.append(target)
    for html_file in sorted(site.rglob("*.html")):
        if html_file.resolve() not in seen:
            problems.append(f"orphan page (not in the catalogue, not linked from it): {html_file.relative_to(site)}")
    total = sum(f.stat().st_size for f in site.rglob("*") if f.is_file())
    if total > DOCROOT_WARN_BYTES:
        warnings.append(f"docroot is {total / 1024 / 1024:.1f} MB (budget 100 MB)")
    for w in warnings:
        print(f"⚠ {w}")
    if problems:
        for pr in problems:
            print(f"✗ {pr}", file=sys.stderr)
        sys.exit(f"check failed: {len(problems)} problem(s) on the {args.target} side")
    print(f"✓ {args.target} check passed ({len(manifest['entries'])} entries, {len(seen)} pages link-checked, docroot {total / 1024:.0f} KB)")


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
    site = site_for(args)
    manifest = load_manifest(site)
    entries = sorted(manifest["entries"], key=lambda e: e.get("order", 999))
    print(f"  {args.target.upper()} catalogue ({site}):\n")
    if not entries:
        print(f"  (empty — no entries shelved yet)")
    for e in entries:
        print(f"  [{e.get('order', '???'):>3}] {e['marker']:<10} {e['slug']:<28} {e['date']:<11} {e['href']}")
    print(f"\n{len(entries)} entries.")


def add_target_arg(sp):
    sp.add_argument("--target", choices=list(SITE_DIRS.keys()), default="public",
                    help="public bhandar (default) or private Antaranga")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--repo", type=Path, default=DEFAULT_REPO,
                   help="bhandar repo root (default: ~/code/homelab/bhandar)")
    sub = p.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("register", help="add or update an entry, then rebuild the index")
    add_target_arg(sp)
    sp.add_argument("--metadata", required=True, help="JSON metadata for one entry (see module docstring)")
    sp.add_argument("--commit", action="store_true", help="git add + commit + push after registering (public only — no-op on private)")
    sp.add_argument("--no-push", action="store_true", help="commit but don't push (only with --commit)")
    sp.add_argument("--allow-missing", action="store_true", help="skip the page audit (register metadata for a page not yet written)")
    sp.set_defaults(func=cmd_register)

    sp = sub.add_parser("remove", help="remove an entry by slug; does NOT delete the page file")
    add_target_arg(sp)
    sp.add_argument("slug")
    sp.set_defaults(func=cmd_remove)

    sp = sub.add_parser("rebuild", help="regenerate index.html from manifest (no metadata change)")
    add_target_arg(sp)
    sp.set_defaults(func=cmd_rebuild)

    sp = sub.add_parser("commit", help="git add + commit + push the bhandar repo (public side only)")
    sp.add_argument("-m", "--message", required=True)
    sp.add_argument("--no-push", action="store_true")
    sp.set_defaults(func=cmd_commit)

    sp = sub.add_parser("check", help="audit a side: entry pages, internal links, orphans, weight budgets")
    add_target_arg(sp)
    sp.set_defaults(func=cmd_check)

    sp = sub.add_parser("list", help="show the catalogue")
    add_target_arg(sp)
    sp.set_defaults(func=cmd_list)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
