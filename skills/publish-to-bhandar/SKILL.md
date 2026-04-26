---
name: publish-to-bhandar
description: Publish a research output, brief, study, ledger, or companion as a Brahma-aesthetic HTML page to the personal library at https://aakashvani.bear-atria.ts.net (Brahma's Bhandar). MUST trigger whenever the user says any of "publish this", "post to bhandar", "post to library", "add to bhandar", "add to the library", "make a wiki page for X", "ship this as a webpage", "put this online", "publish the X research/brief/study/findings"; ALSO trigger proactively whenever a substantive research loop, brief, explainer, or design study is completed within the conversation (offer the user "want me to publish this to the bhandar?"). Generates a single page or a multi-page series in the Brahma visual language (Fraunces / Spectral / JetBrains Mono / vermilion+saffron palette / aged paper), drops the file(s) into ~/code/homelab/bhandar/site/, registers metadata in the manifest, regenerates the library landing index, then commits and pushes — the docker container at aakashvani-caddy serves the new page within a second of git push. Do NOT trigger for one-off file generation that isn't going onto the bhandar (e.g., "make me a webpage" with no library context), and do NOT trigger when the user explicitly only wants a draft they can review before publishing.
---

# publish-to-bhandar

Turn a piece of work into a published page in Brahma's Bhandar.

## What this skill does

Builds and publishes a chapter to the personal library hosted at `https://aakashvani.bear-atria.ts.net`:

1. Picks a name and metadata for the new piece (title, lede, kicker, marker, date, etc.)
2. Generates the HTML page — you write it, using the Brahma aesthetic
3. Registers the entry in `.bhandar/manifest.json`
4. Rebuilds the library catalogue (`site/index.html`)
5. Commits + pushes the bhandar repo
6. Verifies the new URL is live

The repo is `~/code/homelab/bhandar/`. A docker container watches `site/` via a read-only bind mount, so a `git push` is effectively a deploy — no restart needed.

## When to trigger

The frontmatter description handles routing. Mostly: when Dhruv finishes a substantive research output and either says "publish it" or you proactively offer.

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
- **date** — `YYYY-MM-DD`
- **meta_tokens** — array of small mono labels (e.g., `["Six exemplar repos", "~10 min"]`). Date is auto-prepended in the catalog row.
- **open_label** — button text. `"Read"` for most, `"Open Volume I"` for series, `"Open Ledger"` etc.
- **order** — sort key, lower = higher in the catalog. Conventions in `scripts/publish.py`.

### Step 3 — Generate the page

For single-page entries:

1. Read `assets/page-template.html`. It has placeholders: `{{TITLE}}`, `{{DESCRIPTION}}`, `{{WATERMARK_1}}`, `{{WATERMARK_2}}`, `{{KICKER}}`, `{{H1_HTML}}`, `{{SUBTITLE}}`, `{{META_BAR_HTML}}`, `{{BODY}}`, `{{DATE}}`.
2. Substitute placeholders with your metadata. `{{META_BAR_HTML}}` should be `<span>...</span><span class="dot">◆</span><span>...</span>` etc.
3. Write the article body inside `{{BODY}}` using the design system's class vocabulary (h2, h3, p, p.lead, em, strong, code, table, callout, etc. — see `references/design-system.md` for the full list and rules).
4. Save to `~/code/homelab/bhandar/site/<slug>.html`.

For multi-page series:
- Create `~/code/homelab/bhandar/site/<slug>/`
- Write a series-cover `index.html` that links to chapters
- Write each chapter as its own HTML file in `<slug>/<chapter-slug>.html`
- The catalog entry's `href` is `/<slug>/` (the series cover)
- See `~/code/homelab/bhandar/site/local-knowledge/` for a worked example

### Step 4 — Register + rebuild + push

Use `scripts/publish.py register --commit`:

```bash
python3 ~/code/utils/skills/publish-to-bhandar/scripts/publish.py register --metadata '{
  "slug":        "indrajaal",
  "href":        "/indrajaal.html",
  "title_html":  "The Net of <em>Indrajaal</em>",
  "kicker":      "User-flow Study",
  "lede":        "One coherent assistant from four narrow agents — how the threads hold...",
  "marker":      "study",
  "date":        "2026-04-26",
  "meta_tokens": ["Four Hermes profiles", "~14 min"],
  "open_label":  "Read",
  "order":       20
}' --commit
```

The `--commit` flag does git add + commit + push automatically. Use `--no-push` if Dhruv wants to review the diff first.

If you only want to test the index regeneration (no manifest change):
```bash
python3 .../scripts/publish.py rebuild
```

To remove an entry from the catalog (does NOT delete the page file):
```bash
python3 .../scripts/publish.py remove indrajaal
```

To list current catalog:
```bash
python3 .../scripts/publish.py list
```

### Step 5 — Verify the URL

After push, hit the URL to confirm:

```bash
curl -sk -I https://aakashvani.bear-atria.ts.net/<slug>.html | head -3
# expect: HTTP/2 200
```

For multi-page: `https://aakashvani.bear-atria.ts.net/<slug>/`

The docker container has a live bind mount on `site/`, so the file is served the moment git updates the working tree on the Mac Mini. Tell Dhruv the URL.

## Conventions worth respecting

- **Order field** — leave existing entries' `order` alone unless reordering is the point. Pick a value that slots your entry where you want it (e.g., `5` for top-of-catalog, `25` between existing 20 and 30).
- **Dates are absolute** — never "Thursday" or "yesterday". `YYYY-MM-DD` only.
- **Lede is the hook** — write it last, after you've drafted the page. The lede appears on the catalog without page context, so it must stand alone.
- **One callout per page max** — they're scarce on purpose. The most quotable line of the piece, not a section summary.
- **No new files in `site/` except your page and its assets** — the container serves everything in `site/` publicly. Don't drop secrets or work-in-progress drafts there.

## Bundled resources

| File                                  | What it's for                                              |
|---------------------------------------|------------------------------------------------------------|
| `scripts/publish.py`                  | CLI: register, rebuild, remove, commit, list               |
| `scripts/build_index.py`              | Library landing generator (called by publish.py)           |
| `assets/page-template.html`           | Standalone-page template — substitute placeholders         |
| `references/design-system.md`         | Palette, fonts, naming, class vocabulary, content rules    |

## When NOT to use this skill

- Dhruv asks for a "draft" or "preview" he wants to see before publishing → write the file somewhere outside `~/code/homelab/bhandar/site/` first; don't auto-commit.
- The work isn't intended for the library (e.g., an internal CLAUDE.md update, a script, a config file).
- Dhruv is iterating on the design system itself or on the page template — that's a different conversation.
