# LLM Wiki Schema

> Generated from `agents/llm-wiki/assets/llm-wiki-schema.template.md`.
> This is the operating guide for the `llm-wiki` agent.

---

## Core Model

LLM Wiki has three layers:

1. **Raw sources**: immutable user-owned documents under `{raw-root}`. The agent reads these files but never modifies them.
2. **Wiki**: generated markdown under `{wiki-root}`. The agent owns creation, updates, links, summaries, and bookkeeping.
3. **Schema**: this guide plus the `llm-wiki` agent definition. It defines page types, workflows, provenance, and maintenance rules.

The goal is compilation, not repeated retrieval. Sources are read once, distilled
into stable wiki pages, then kept current as new sources and useful questions
arrive.

---

## Directory Structure

```text
{raw-root}/
  source files, attachments, clipped articles, transcripts, reports

{wiki-root}/
  index.md
  overview.md
  glossary.md
  log.md
  sources/
  concepts/
  analyses/
  products/
  features/
  personas/
  style/
```

Create optional directories only when the domain needs them, for example:
`decisions/`, `people/`, `companies/`, `projects/`, `papers/`, `apis/`.

---

## Page Types

| Type | Default Location | Purpose |
|---|---|---|
| `source` | `{wiki-root}/sources/` | One summary page per raw source: metadata, key facts, notable quotes, affected pages |
| `concept` | `{wiki-root}/concepts/` | A domain idea, term, mechanism, or recurring theme |
| `analysis` | `{wiki-root}/analyses/` | Saved answer, comparison, gap analysis, synthesis, outline, or decision support note |
| `product` | `{wiki-root}/products/` | Product, service, tool, or platform |
| `feature` | `{wiki-root}/features/` | Product feature or capability |
| `persona` | `{wiki-root}/personas/` | Audience, user group, stakeholder, or customer segment |
| `style` | `{wiki-root}/style/` | Naming, writing, tone, documentation, or terminology rule |

If content does not fit these types, propose a new type before creating a new
directory.

---

## Page Format

Every wiki page should start with YAML frontmatter:

```yaml
---
title: ""
type: source | concept | analysis | product | feature | persona | style
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: []
tags: []
status: draft | current | stale | superseded
---
```

Then use this body structure:

1. One-line summary used by `index.md`
2. Body with concise headings, lists, and tables where useful
3. Provenance or evidence notes when claims depend on specific sources
4. Open questions or contradictions when relevant
5. Related pages using `[[filename-without-extension]]` links

Use kebab-case filenames. Keep page titles aligned with filenames.

---

## Core Files

### `index.md`

Content-oriented catalog. Read this first for queries, ingests, and lint work.
List pages by type with link, one-line summary, status, and last updated date.

### `overview.md`

Big-picture synthesis of the full wiki. Update when a source changes the overall
understanding, not for every minor fact.

### `glossary.md`

Canonical terms, definitions, variants, deprecated terms, and preferred wording.
Check this before writing or updating pages with domain terminology.

### `log.md`

Append-only chronological record. Use parseable headings:

```markdown
## [YYYY-MM-DD] ingest | Source Title
## [YYYY-MM-DD] query | Question Summary
## [YYYY-MM-DD] lint | Scope
## [YYYY-MM-DD] schema | Change Summary
```

Do not rewrite older log entries except to fix obvious formatting damage.

---

## Workflow: Bootstrap

1. Confirm `{raw-root}` and `{wiki-root}`.
2. If target wiki files already exist, summarize what exists and ask before overwriting.
3. Create required directories.
4. Create starter `index.md`, `overview.md`, `glossary.md`, and `log.md`.
5. Create optional directories for enabled page types.
6. Record the initialization in `log.md`.

---

## Workflow: Ingest

When the user asks to ingest a source:

1. Verify the source is inside `{raw-root}` or explicitly provided by the user.
2. Read the source without modifying it.
3. Read `index.md`, `glossary.md`, and recent `log.md` entries.
4. Identify existing pages affected by the source.
5. Create or update a `sources/` summary page.
6. Update existing entity, concept, style, or analysis pages where the source changes or strengthens knowledge.
7. Create new pages only when existing pages do not fit.
8. Update `glossary.md` for new or conflicting terms.
9. Update `index.md`.
10. Update `overview.md` only if the big picture changed.
11. Append an ingest entry to `log.md`.
12. Report pages created, pages updated, contradictions, and open questions.

If a source contradicts existing pages, flag the contradiction before applying
the update unless the configured contradiction policy says otherwise.

---

## Workflow: Query

When the user asks a question:

1. Read `index.md`.
2. Select relevant pages and read only those pages.
3. Check `glossary.md` when terminology matters.
4. Answer using wiki citations and clear provenance.
5. Distinguish source facts, synthesis, and uncertainty.
6. Ask whether to save the answer as an analysis page unless auto-save is configured.
7. If saved, write to `analyses/`, update `index.md`, and append a query log entry.

Do not default to raw-source search unless the wiki lacks coverage or the user
asks for source-level verification.

---

## Workflow: Lint

When the user asks to lint the wiki:

1. Read `index.md`, `glossary.md`, `overview.md`, and recent `log.md`.
2. Scan wiki pages in batches if needed.
3. Report:
   - contradictions between pages
   - stale claims superseded by newer sources
   - orphan pages with no inbound links
   - important terms without glossary entries
   - missing cross-references
   - inconsistent terminology
   - pages without source provenance
4. Propose fixes with affected paths.
5. Ask before applying fixes.
6. Append a lint entry to `log.md`.

---

## Cross-Reference Rules

- Use `[[filename-without-extension]]` for internal links.
- Add back-links when a new page meaningfully depends on an existing page.
- Keep `overview.md` and `glossary.md` linked to major entities and concepts.
- Avoid link spam; links should help future readers or future LLM sessions navigate.

---

## Provenance Rules

- Raw sources are the evidence layer.
- Wiki pages are compiled knowledge, not primary evidence.
- Source summaries must identify the raw file or external source.
- Analysis pages must list pages consulted.
- If a claim is inferred from several pages, mark it as synthesis.
- If source support is weak or conflicting, say so plainly.

---

## Schema Evolution

Change the schema when repeated work shows the current page types or workflows do
not fit the user's domain.

Before changing schema:

1. Explain the problem.
2. Propose the new type, directory, frontmatter field, or workflow rule.
3. Show migration impact on existing pages.
4. Ask for approval.
5. Apply the smallest useful change.
6. Log the schema change.
