# Bhandar Design System

The Brahma aesthetic, scoped to bhandar pages. Use these tokens, classes, and naming conventions when generating page content. All CSS lives in the canonical stylesheets (`assets/bhandar.css` for articles, `assets/catalogue.css` for the catalogue) — templates link them, pages never inline styles. You only write HTML inside `<article>`.

## Palette

| Token         | Hex       | Usage                                              |
|---------------|-----------|----------------------------------------------------|
| `--paper`     | `#ede4d0` | Background — aged manuscript cream                 |
| `--paper-warm`| `#e3d8bf` | Hovered rows, callout backgrounds                  |
| `--ink`       | `#1a1f2e` | Body text                                          |
| `--ink-soft`  | `#3a4256` | Lede italic, blockquote                            |
| `--ink-fade`  | `#6c7388` | Mono labels, meta lines                            |
| `--vermilion` | `#c8421e` | H1 em accents, links, callout border, kicker stars |
| `--saffron`   | `#d9941a` | Devanagari, dots, ornament marks, separators       |
| `--verdigris` | `#6b8e7f` | Inline `<code>` color                              |
| `--crimson`   | `#8b3a3a` | Companion marker bg, link hover                    |
| `--gold`      | `#b08544` | Roman numerals on the catalog                      |
| `--gold-deep` | `#8a6418` | Drop cap, h4 mono labels, kicker text              |
| `--rule`      | `#c4b89d` | Section dividers                                   |
| `--rule-faint`| `#d4c8ad` | Subtle row borders                                 |

## Typography

| Family            | When                                                          |
|-------------------|---------------------------------------------------------------|
| **Fraunces**      | Display: H1, H2, blockquote, callout, lede drop cap. Use the `WONK 1`, `SOFT 50–100`, `opsz 96–144` axes for character. |
| **Spectral**      | Body prose. Italic 300 for ledes and asides.                  |
| **JetBrains Mono**| Kickers, meta tokens, table headers, h4-style category labels, code, code blocks. |

## Naming convention

Existing pages use `<Object> of <Hindu deity>`. Pattern + examples:

| Page         | Pattern                                          |
|--------------|--------------------------------------------------|
| Chitragupta  | "The Ledger of Chitragupta" — deity is the divine accountant; ledger is his domain |
| Indrajaal    | "The Net of Indrajaal" — Indra's net is illusion/perception |
| Saraswati    | "The Veena of Saraswati" — her instrument        |
| Volume I     | "A Study in Local Knowledge" — descriptive when no deity fits cleanly |
| Atomic Agents | descriptive — "A Brief in Five Schematics" — no deity |

When picking a name for a new piece:
- Look for a Hindu/Vedic figure whose attribute matches the topic. *Don't force it* — a contrived match is worse than an honest descriptive title.
- Common candidates: Brahma (creation/composition), Vishnu (preservation/recurrence), Shiva (destruction/transformation), Ganesha (writing/scribing/obstacles), Hanuman (search/retrieval/devotion), Yama (judgment/finality), Surya (illumination), Indra (governance/networks), Agni (transformation/transmission), Varuna (cosmic order), Aryaman (hospitality/guests), Nataraja (dance of reality/states), Akashvani (broadcast/voice from sky), Smriti (memory/codification), Vyasa (compilation/editing), Valmiki (the originator's witness).
- Object should be material/concrete: ledger, net, veena, kosha (treasury), pothi (manuscript), vimana (vehicle/architecture), darpana (mirror), srotas (channel/stream), bhandar (storehouse — already used as the parent).
- Result format: `"The <Object> of <Deity>"` for the title, slug = lowercase deity (`indrajaal`, `chitragupta`).

## Markers (categories)

Each entry on the catalog gets one marker. The marker shows as a colored chip and informs the reader what kind of artifact this is.

| Marker      | Color    | Use for                                                          |
|-------------|----------|------------------------------------------------------------------|
| `research`  | vermilion | A research loop / investigation / multi-cycle inquiry            |
| `study`     | verdigris | A focused inquiry into a specific topic — flow, mechanism, design|
| `brief`     | saffron   | A short primer / explainer / 5-min concept piece                 |
| `companion` | crimson   | A pedagogical / teaching companion to another piece              |
| `series`    | gold      | A multi-page bound work (Volume I/II/III) with chapters          |

## Page anatomy (single-page entry)

The standalone-page template at `assets/page-template.html` provides:

```
<main>
  <span class="watermark wm-1">{{WATERMARK_1}}</span>          ← devanagari char, scattered
  <span class="watermark wm-2">{{WATERMARK_2}}</span>

  <nav class="crumbs">                                          ← back-to-bhandar breadcrumb
    <a href="/">The Bhandar</a> ◆ {{KICKER}}
  </nav>

  <header class="page-header">
    <div class="kicker">{{KICKER}}</div>                        ← uppercase mono, ◆ flanked
    <h1>{{H1_HTML}}</h1>                                        ← Fraunces, em accent
    <p class="subtitle">{{SUBTITLE}}</p>                        ← Spectral italic
    <div class="meta-bar">{{META_BAR_HTML}}</div>               ← <span>...</span> tokens
  </header>

  <article>                                                     ← THIS is where your content goes
{{BODY}}
  </article>

  <footer class="colophon">...</footer>
</main>
```

Inside `<article>`, available semantic markup (all pre-styled, no inline CSS):

| Tag / class                    | Renders as                                              |
|--------------------------------|---------------------------------------------------------|
| `<h2>`                         | Fraunces section heading, top-rule divider              |
| `<h2><em>X</em></h2>`          | em becomes vermilion italic                             |
| `<h3>`                         | Subsection — Fraunces medium                            |
| `<h4>`                         | Mono uppercase label — for inline category tags         |
| `<p>`                          | Body prose                                              |
| `<p class="lead">`             | First paragraph; gets a Fraunces drop cap on the first letter — use ONCE, before any `<h2>` |
| `<em>`                         | Italic                                                  |
| `<strong>`                     | Bold ink                                                |
| `<code>`                       | Verdigris on faint green tile                           |
| `<pre><code>`                  | Saffron-bordered code block                             |
| `<blockquote><p>...</p>...</blockquote>` | Italic Fraunces with saffron rule                |
| `<ul>` / `<ol>` / `<li>`       | Lists with gold markers                                 |
| `<table><thead>...<tbody>...`  | Mono uppercase headers, row hover                       |
| `<hr>`                         | Centered divider, max 200px                             |
| `<div class="callout"><span class="label">Key Finding</span> ...</div>` | Pull-out box with vermilion left border. AT MOST ONE per page — the single most consequential takeaway. |
| `<div class="note-card"><span class="label">Note</span> ...</div>` | Quiet grouped note — use instead of a second callout. |
| `<div class="spec-card"><span class="label">Specs</span> ...</div>` | Mono grouped facts (versions, sizes, settings) — instead of a second callout. |
| `<div class="table-scroll"><table>…</table></div>` | REQUIRED wrapper for every table, so wide tables scroll inside the wrapper on phones. |

Use HTML entities for typography: `&mdash;` `&ndash;` `&rarr;` `&hellip;` `&ldquo;` `&rdquo;` `&amp;` `&#9733;` (★).

## Watermark suggestions

Pick devanagari characters that resonate with the page topic. Examples:

| Topic            | Suggested watermark chars                              |
|------------------|---------------------------------------------------------|
| Memory / wisdom  | `&#x092C;` (ब – Brahma), `&#x0938;` (स – Smriti), `&#x0935;` (व – Vidya) |
| Architecture     | `&#x092D;` (भ – building/structure)                    |
| Generic          | `&#x0917;&#x094D;&#x0930;&#x0902;&#x0925;` (ग्रन्थ – text) |
| Networks / nets  | `&#x092A;` (प) or `&#x091C;` (ज – jaal)                |

If unsure, default to `&#x092C;` and `&#x0917;&#x094D;&#x0930;&#x0902;&#x0925;` — Brahma + grantha — fits everything in this library.

## What good content looks like

- Lede paragraph reads like the cold open of a New Yorker article — concrete, specific, low on jargon. Sets up the question.
- H2 sections are noun phrases, not gerunds — "The Question" not "Asking the Question". Em-accent the noun that carries the meaning.
- Callouts are short — under 50 words. The most quotable line of the piece.
- Tables when there's a real comparison; lists when there's a real enumeration; never both.
- Closing section is a one- or two-sentence resolution, not a "Conclusion" header.

## The private side — Antaranga

The bhandar has a sibling site at `site-private/` served by a second Tailscale identity (`aakashvani-private`) with no Funnel — reachable only on the tailnet. Its catalog is the **Antaranga** (अन्तरङ्ग, "inner / inner sanctum").

**When pages go to Antaranga rather than the public Bhandar:**
- Anything carrying real names beyond Dhruv's, addresses, account/credential identifiers, financial figures, photos of identifiable people, or internal notes about specific contacts/vendors.
- Drafts Dhruv wants synced across his devices but not shared.
- Anything Dhruv explicitly tags `private`, `tailnet only`, `antaranga`.

**Visual differences from the public side:**
- Lock band immediately under the seal: `<div class="lock-band"><span class="glyph">●</span> Tailnet only · Aakashvani-Private</div>` — crimson border, JetBrains Mono uppercase. Renders only because the private manifest's `site` block sets `lock_band_html`.
- Watermarks: `अ` + `अन्तरङ्ग` + `गुप्त` instead of public's `ब` + `ग्रन्थ` + `भ`.
- Aphorism: "*यदन्तरं तद् ब्रह्म* — That which is within, that indeed is Brahman" — inner-focused.
- Colophon ends with the private hostname.

**Manifest-level overrides** (all optional in the `site` block — fall back to public defaults if missing):
- `lock_band_html` — full HTML for the badge, or omit on the public side
- `watermarks_html` — three `<span class="watermark wm-1/2/3">…</span>` tags
- `aphorism_html` — sanskrit + translation
- `colophon_html` — supports `{entry_count}` substitution

The page-template aesthetic itself is identical on both sides — only the catalog landing differs.

**Discoverability:** the private side is invisible to the public internet by design (no public DNS record, Funnel off). Default behavior is correct; you don't need to mark individual pages as private — putting them in `site-private/` is the entire access control.


## Platform contract (relaunch, 2026-10-26)

The rules below are enforced by `publish.py` and the Caddy config, not by taste. They exist because the April–August library drifted in exactly these places.

**Canonical stylesheets.** One stylesheet per page type, owned by this skill: `assets/bhandar.css` (articles) and `assets/catalogue.css` (catalogue). `build_index.py` copies both, plus `assets/favicon.svg`, into each docroot's `/assets/` on every rebuild. Pages link `/assets/bhandar.css`; the catalogue links `/assets/catalogue.css`. Never inline a `<style>` block in a page, and never copy a stylesheet into a page directory. A design fix lands in the skill asset and propagates on the next rebuild. The one sanctioned variant is a report page's small additional classes, defined in `bhandar.css` itself — there is no second forked stylesheet.

**Head metadata.** Every page ships: `<title>`, a meta `description` (required, non-empty, and identical to the manifest entry's `description` — register refuses a mismatch), favicon (`/assets/favicon.svg`), `theme-color`, a canonical URL, and Open Graph tags (`og:type`, `og:title`, `og:description`, `og:url`) fed from the same title/description. The catalogue index gets the same treatment from its manifest `site` block (`description`, `canonical_url`).

**Zero JavaScript.** The CSP sends `script-src 'none'` and `publish.py` refuses any page containing a script element. Interactive demos do not belong on these sites.

**Responsive contract.** Design at three widths: 1100px (article column), 720px, 480px. Watermarks sit inside `.watermark-layer`, a clipped layer, so oversized glyphs never cause horizontal scroll; `html, body` also carry `overflow-x: clip`. Every table is wrapped in `.table-scroll`. Figures cap at the column width; images are `max-width: 100%`. Print strips decoration (grain, watermarks, crumbs, chapter nav) via the `@media print` block in the canonical sheets.

**Series pattern.** A series is a folder `<slug>/` with a cover `index.html` built from `assets/series-cover-template.html` (about-the-series prose + an ordered `.reading-list` of chapters) and chapters built from `assets/chapter-template.html` (crumbs back to the cover, `.chapter-nav` with prev / cover / next). Chapter navigation is explicit HTML — there is no runtime generation. The catalogue tracks the series only; chapters are reached through the cover, and `publish.py check` verifies none are orphaned.

**Lock band.** One component, `.lock-band`, defined identically in both canonical sheets: crimson border, mono uppercase, `● Tailnet only · Antaranga`. The private catalogue renders it from the manifest; private article pages include the same markup under the header (the page template carries it as a commented block to enable).

**Callout budget.** One `.callout` per page, hard cap. Everything that used to be a second or third callout is a `.note-card` (prose) or `.spec-card` (mono facts) instead.

**Weight budgets.** Single page ≤ 100 KB HTML (warning) / 500 KB (hard fail); images ≤ 300 KB each where practical; audio ≤ 5 MB; binaries ≤ 25 MB each, versioned filenames under `/downloads/<slug>/`, never a mutable `-latest` name; a docroot stays ≤ 100 MB total, keeping only the current and previous binary build.

**Layout.** One folder per article or series: `<slug>.html` for singles, `<slug>/` with its own `assets/` for series. Shared assets live once, under `/assets/`. Internal links must resolve — `publish.py check` crawls from the catalogue and fails on broken links and orphan pages. Counts on the catalogue (volumes shelved) are generated from the manifest, never hand-typed.
