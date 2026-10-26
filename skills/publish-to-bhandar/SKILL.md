---
name: publish-to-bhandar
description: Publish a research output, brief, study, ledger, or companion as a Brahma-aesthetic HTML page to either the public library (Brahma's Bhandar — https://aakashvani.bear-atria.ts.net, internet-accessible) or the private library (Antaranga — https://aakashvani-private.bear-atria.ts.net, tailnet-only). MUST trigger whenever the user says any of "publish this", "post to bhandar", "post to library", "post to antaranga", "add to bhandar", "add to the library", "make a wiki page for X", "ship this as a webpage", "put this online", "publish the X research/brief/study/findings", "save this privately to the bhandar", "private publish"; ALSO trigger proactively whenever a substantive research loop, brief, explainer, or design study is completed within the conversation (offer the user "want me to publish this to the bhandar?"). For PII-bearing or otherwise sensitive content, default to the private side (Antaranga). Generates a single page or a multi-page series in the Brahma visual language (Fraunces / Spectral / JetBrains Mono / vermilion+saffron palette / aged paper), drops the file(s) into the right docroot, registers metadata in the manifest, regenerates the catalogue, and (for public pages only) commits and pushes — the relevant docker container serves the new page within a second. Do NOT trigger for one-off file generation that isn't going onto the bhandar (e.g., "make me a webpage" with no library context), and do NOT trigger when the user explicitly only wants a draft they can review before publishing.
---

# publish-to-bhandar

Turn a piece of work into a published page in Brahma's Bhandar — either the **public** side (the Bhandar, internet-facing) or the **private** side (the Antaranga, tailnet-only for PII).

## What this skill does

Builds and publishes a chapter to one of two libraries:

| Side | URL | Audience | Persistence |
|------|-----|----------|-------------|
| **Public** (Bhandar) | `https://aakashvani.bear-atria.ts.net` | Anyone with the link | git-tracked, pushed to GitHub |
| **Private** (Antaranga) | `https://aakashvani-private.bear-atria.ts.net` | Only your tailnet devices | local-only (gitignored, never pushed) |

The pipeline is the same for both:

1. Pick a name and metadata for the new piece (title, lede, kicker, marker, date, etc.)
2. Generate the HTML page — you write it, using the Brahma aesthetic
3. Register the entry in the right `.bhandar/manifest.json`
4. Rebuild the catalogue index for that side
5. (Public only) Commit + push the repo
6. Verify the new URL is live

The repo is `~/code/homelab/bhandar/`. Two docker container pairs watch their respective docroots via read-only bind mounts, so a file save is effectively a deploy — no restart needed.

## When to trigger

The frontmatter description handles routing. Mostly: when Dhruv finishes a substantive research output and either says "publish it" or you proactively offer.

## Public vs Private — which side?

Default to **public** unless one of these is true:

- The page contains PII (real names beyond Dhruv's, addresses, account numbers, financial detail, photos of people)
- It contains internal notes about specific people (vendors, contacts, family)
- It's a draft Dhruv wants to share with himself across devices but not the world
- Dhruv explicitly says "private", "antaranga", or "tailnet only"

When in doubt, ASK. Once a page is published publicly, taking it down requires a force-push that likely leaves a cache trail.

## Workflow

### Step 1 — Capture intent

Identify what's being published. Most commonly one of:

| Source                                              | What you do                                           |
|-----------------------------------------------------|-------------------------------------------------------|
| A markdown research file (e.g., `~/code/.../findings.md`) | Read it. Convert to editorial HTML body.       |
| Output from this conversation                       | Synthesize a clean draft from the convo content.      |
| An existing draft elsewhere                         | Read it. Adapt to bhandar structure.                  |
| A multi-chapter series (like memory-system Volume I)| Build a `<slug>/` subdirectory with index + chapters. |

### Step 2 — Pick a name + metadata

Read `references/design-system.md` for the naming convention and marker categories. The naming pattern is `<Object> of <Hindu deity>` when a deity fits naturally — don't force it.

Decide:
- **slug** — lowercase, kebab-case, filename-safe (e.g., `indrajaal`, `local-knowledge`, `nataraja`)
- **href** — `/<slug>.html` for single-page, `/<slug>/` for multi-page series
- **title_html** — display title with `<em>X</em>` accent on the deity/key word
- **kicker** — short uppercase mono label, e.g., `"Survey · Cycle iii"` or `"User-flow Study"`
- **lede** — one-sentence pull, italic Spectral on the catalog. Should make the reader want to click.
- **marker** — one of `research`, `study`, `brief`, `companion`, `series`. See design system for what each means.
- **description** — one-sentence summary, REQUIRED. It goes in the manifest AND must match the page's `<meta name="description">` exactly — `publish.py register` refuses the entry if either is missing or they disagree. It also feeds the page's Open Graph tags.
- **date** — `YYYY-MM-DD`
- **meta_tokens** — array of small mono labels (e.g., `["Six exemplar repos", "~10 min"]`). Date is auto-prepended in the catalog row.
- **open_label** — button text. `"Read"` for most, `"Open Volume I"` for series, `"Open Ledger"` etc.
- **order** — sort key, lower = higher in the catalog. Conventions in `scripts/publish.py`.

### Step 3 — Generate the page

For single-page entries:

1. Read `assets/page-template.html`. It has placeholders: `{{TITLE}}`, `{{DESCRIPTION}}`, `{{CANONICAL_URL}}` (the page's own absolute URL), `{{WATERMARK_1}}`, `{{WATERMARK_2}}`, `{{KICKER}}`, `{{H1_HTML}}`, `{{SUBTITLE}}`, `{{META_BAR_HTML}}`, `{{BODY}}`, `{{DATE}}`. All styling comes from the canonical `/assets/bhandar.css` — never inline a `<style>` block, and never add script elements (the sites are zero-JS and register will refuse them).
2. Substitute placeholders with your metadata. `{{META_BAR_HTML}}` should be `<span>...</span><span class="dot">◆</span><span>...</span>` etc.
3. Write the article body inside `{{BODY}}` using the design system's class vocabulary (h2, h3, p, p.lead, em, strong, code, table, callout, etc. — see `references/design-system.md` for the full list and rules).
4. Save to:
   - **Public:** `~/code/homelab/bhandar/site/<slug>.html`
   - **Private:** `~/code/homelab/bhandar/site-private/<slug>.html`

For multi-page series:
- Create `~/code/homelab/bhandar/site/<slug>/` (or `site-private/<slug>/`)
- Start the cover from `assets/series-cover-template.html` and chapters from `assets/chapter-template.html` (reading-list + prev/cover/next navigation are pre-styled)
- Write a series-cover `index.html` that links to chapters
- Write each chapter as its own HTML file in `<slug>/<chapter-slug>.html`
- The catalog entry's `href` is `/<slug>/` (the series cover)

#### Adding a chapter to an existing series — HARD RULE

The manifest tracks **series, not chapters**. That means when you add a new chapter HTML file to an existing `<slug>/` dir, `publish.py register` will NOT pick it up — the slug is already registered. Two things you MUST do by hand:

1. **Add a `<li><a href="<new-chapter>.html">…</a></li>` block to the series `index.html`**, in the same style as the existing chapter list. Without this, the chapter is unreachable from the catalog — it just sits on disk, served but invisible. (The Bhandar drift-check hook will flag it on next session start.)
2. **Update the manifest entry's `meta_tokens` array** to reflect the new chapter count and time estimate. E.g. `["Four chapters", "~18 min", "Three diagrams"]` → `["Five chapters", "~23 min", "Three diagrams"]`. Edit `.bhandar/manifest.json` directly or run a `jq` rewrite. The catalog tile shows these tokens.

**Past incident:** `kubera-vimana/shipped.html` was authored 2026-04-27 but the series index was last touched 2026-04-26 — the chapter was published-but-unlinked for 26 days until the May 23 audit caught it. Don't repeat this.

### Step 4 — Register + rebuild (+ push if public)

`publish.py` defaults to `--target public`. Add `--target private` for the Antaranga.

**Public example:**
```bash
python3 ~/code/utils/skills/publish-to-bhandar/scripts/publish.py register --commit --metadata '{
  "slug":        "indrajaal",
  "href":        "/indrajaal.html",
  "title_html":  "The Net of <em>Indrajaal</em>",
  "kicker":      "User-flow Study",
  "description": "How four narrow agent profiles compose into one coherent assistant.",
  "lede":        "One coherent assistant from four narrow agents — how the threads hold...",
  "marker":      "study",
  "date":        "2026-04-26",
  "meta_tokens": ["Four Hermes profiles", "~14 min"],
  "open_label":  "Read",
  "order":       20
}'
```

**Private example** — same fields, just add `--target private`. The `--commit` flag is a no-op on the private side (the docroot is gitignored), but it's harmless to leave in:
```bash
python3 ~/code/utils/skills/publish-to-bhandar/scripts/publish.py register --target private --metadata '{
  "slug":  "vendor-list-2026",
  "href":  "/vendor-list-2026.html",
  ...
}'
```

`register` audits the page BEFORE touching the manifest and refuses (leaving the catalogue unchanged) when the page is missing, contains script elements or unfilled placeholders, lacks a title/lang/meta description, has a description that disagrees with the manifest, nests anchors, duplicates ids, or exceeds the 500 KB hard page limit. `--allow-missing` skips the audit for metadata-only registration of a page not yet written — use it rarely.

Other commands all accept `--target`:
```bash
publish.py rebuild --target private              # regen Antaranga catalog
publish.py list    --target private              # show private entries
publish.py remove  --target private vendor-list  # remove from catalog (page stays)
publish.py check   --target private              # audit the whole side: entry pages,
                                                 # every internal link, orphan pages,
                                                 # and weight budgets. Run after any
                                                 # multi-page work (series chapters esp.)
```

### Step 5 — Verify (URL + manifest + reachability)

Three checks before declaring "published". A green URL alone is not enough — Bhandar serves anything on disk whether or not it's in the catalog.

**A. URL is live:**
```bash
# public:
curl -sk -I https://aakashvani.bear-atria.ts.net/<slug>.html | head -3
# private (must be on tailnet):
curl -sk -I https://aakashvani-private.bear-atria.ts.net/<slug>.html | head -3
# expect: HTTP/2 200
```

**B. Catalog entry actually landed in the manifest:**
```bash
# new top-level entry — slug must appear:
jq -r '.entries[].slug' ~/code/homelab/bhandar/site/.bhandar/manifest.json | grep -x '<slug>'
# new chapter in an existing series — meta_tokens must be updated:
jq '.entries[] | select(.slug == "<series-slug>") | .meta_tokens' ~/code/homelab/bhandar/site/.bhandar/manifest.json
```

**C. Reachability from the catalog/series index** (the silent failure mode):
```bash
# new top-level entry — must be linked from the catalog index:
grep -q 'href="/<slug>' ~/code/homelab/bhandar/site/index.html
# new chapter — must be linked from the series index:
grep -q 'href="<chapter>.html"' ~/code/homelab/bhandar/site/<series>/index.html
```

If any of B/C fails: the page is published-but-invisible. Fix before telling Dhruv the URL — a URL that's not in the catalog is one that no one will ever find.

The docker containers have live bind mounts, so the file is served the moment it lands on disk.

## Conventions worth respecting

- **Order field** — leave existing entries' `order` alone unless reordering is the point. Pick a value that slots your entry where you want it (e.g., `5` for top-of-catalog, `25` between existing 20 and 30).
- **Dates are absolute** — never "Thursday" or "yesterday". `YYYY-MM-DD` only.
- **Lede is the hook** — write it last, after you've drafted the page. The lede appears on the catalog without page context, so it must stand alone.
- **One callout per page max** — they're scarce on purpose. The most quotable line of the piece, not a section summary.
- **No new files in `site/` except your page and its assets** — the container serves everything in `site/` publicly. Don't drop secrets or work-in-progress drafts there. Use `site-private/` instead.
- **Public-vs-private is hard to undo** — taking down a public page requires force-pushing git history and trusting that no one cached it. When in doubt, publish private first; promote to public later.
- **Site-level tone is set by the manifest** — both manifests' `site` blocks carry the title, h1, devanagari, watermarks, lock band, aphorism, and colophon. To change the look of either side, edit the manifest's `site` block, not the build script.

## Bundled resources

| File                                  | What it's for                                              |
|---------------------------------------|------------------------------------------------------------|
| `scripts/publish.py`                  | CLI: register, rebuild, remove, commit, list, check        |
| `scripts/build_index.py`              | Library landing generator (called by publish.py)           |
| `assets/page-template.html`           | Standalone-page template — substitute placeholders         |
| `references/design-system.md`         | Palette, fonts, naming, class vocabulary, content rules    |

## Anti-patterns

- **Writing a new sub-chapter HTML into an existing `<slug>/` directory and stopping there.** The catalog manifest tracks series, not chapters — the chapter is served but unreachable until you add it to the series index page AND bump `meta_tokens`. See Step 3's "Adding a chapter to an existing series" block.
- **Calling Step 5 done on URL response code alone.** HTTP 200 means the file is on disk; it does NOT mean the catalog knows about it. Run checks B and C (manifest entry + catalog/index link) before telling Dhruv "it's live."
- **Batching multiple new pages and only registering the last one.** Every published file needs its own `register` call (or, for series chapters, its own index-page edit). Don't loop through a list and run register once at the end — silent omissions sneak in.
- **Editing `.bhandar/manifest.json` directly for a new top-level entry** instead of using `publish.py register`. The script does field validation, sort key handling, and catalog rebuild atomically. Direct edits skip the rebuild → the catalog index goes stale.

## When NOT to use this skill

- Dhruv asks for a "draft" or "preview" he wants to see before publishing → write the file somewhere outside `~/code/homelab/bhandar/site/` first; don't auto-commit.
- The work isn't intended for the library (e.g., an internal CLAUDE.md update, a script, a config file).
- Dhruv is iterating on the design system itself or on the page template — that's a different conversation.
