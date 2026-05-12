---
name: llm-wiki-ingest
description: >
  Compiles raw source documents into a persistent interlinked markdown wiki.
  Use when: the user says ingest, process a raw source, compile documents into
  the wiki, summarize a source into wiki pages, update wiki pages from new
  evidence, or integrate new knowledge into the LLM Wiki.
license: MIT
compatibility: opencode
metadata:
  owner: llm-wiki
  type: read-write
  approval: "No for read-only source analysis; Yes before broad overwrite of existing pages"
---

# llm-wiki-ingest

**Owner**: `llm-wiki`
**Type**: `read-write`
**Approval**: `No for read-only source analysis; Yes before broad overwrite of existing pages`

---

## What I Do

Reads an immutable source, creates or updates the source summary page, updates
affected wiki pages, refreshes glossary/index/overview as needed, and appends a
chronological ingest log entry.

---

## When to Use Me

- User says `ingest raw/file.md` or equivalent
- A new source should become durable wiki knowledge
- Existing wiki pages need to be updated from new evidence
- The user wants source facts organized into concepts, products, features, personas, style rules, or analyses

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/llm-wiki/MEMORY.md

Loads during execution (lazy):
  .crux/docs/llm-wiki-schema.md       (generate from agent assets first if missing)
  {wiki-root}/index.md
  {wiki-root}/glossary.md
  {wiki-root}/overview.md if big-picture synthesis may change
  {wiki-root}/log.md last 5 entries
  relevant existing wiki pages identified from index.md
  requested source file under {raw-root}

Estimated token cost: source size + ~1200 tokens
Unloaded after: ingest report and wiki updates complete
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `source-path` | user | Yes |
| `raw-root` | MEMORY.md / user | No — default: `raw/` |
| `wiki-root` | MEMORY.md / user | No — default: `wiki/` |
| `emphasis` | user | No |
| `contradiction-policy` | MEMORY.md | No — default: ask-before-update |

---

## Steps

```
1. Validate source path
   Confirm source is under raw-root unless user explicitly provided it.
   Never modify source files.

2. Load orientation
   Read .crux/docs/llm-wiki-schema.md.
   Read wiki-root/index.md.
   Read wiki-root/glossary.md.
   Read last 5 entries from wiki-root/log.md.

3. Read source
   Extract:
     - bibliographic or file metadata
     - key facts
     - notable source-supported claims
     - terminology
     - entities, concepts, products, features, personas, style rules, or domain-specific page candidates
     - contradictions or stale claims relative to existing wiki pages

4. Identify affected pages
   Prefer updating existing pages found from index.md.
   Create new pages only when no existing page fits.

5. Present update plan when changes are broad or contradictions exist
   Include pages to create, pages to update, glossary changes, overview changes, and contradictions.

6. Write or update source summary
   Target: wiki-root/sources/{source-slug}.md

7. Update affected wiki pages
   Preserve page provenance.
   Add source filename to frontmatter sources.
   Update related pages.

8. Update glossary
   Add new canonical terms.
   Flag variants, deprecated terms, or conflicts.

9. Update index
   Add new pages and update summaries/status for changed pages.

10. Update overview only if synthesis changed

11. Append log entry
   Format: ## [YYYY-MM-DD] ingest | {Source Title}

12. Return ingest report
   Include pages created, pages updated, contradictions, glossary changes, and open questions.
```

---

## Output

**Writes to**: `{wiki-root}/sources/`, relevant `{wiki-root}/**/*.md`, `{wiki-root}/index.md`, `{wiki-root}/glossary.md`, `{wiki-root}/overview.md`, `{wiki-root}/log.md`
**Format**: `markdown`

### Source summary format

```markdown
---
title: "{Source Title}"
type: source
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: ["{raw source path}"]
tags: []
status: current
---

One-line summary.

## Metadata

| Field | Value |
|---|---|
| Source path | `{source-path}` |
| Ingested | YYYY-MM-DD |

## Key Facts

- ...

## Notable Evidence

- ...

## Affected Pages

- [[page-name]] — reason

## Contradictions Or Tensions

- ...

## Open Questions

- ...

## Related Pages

- [[page-name]]
```

### Log entry format

```markdown
## [YYYY-MM-DD] ingest | {Source Title}

Source: `{source-path}`
Pages created: ...
Pages updated: ...
Key additions: ...
Contradictions: ...
Open questions: ...
```

---

## Approval Gate

```
Ask before:
  - changing more than 10 wiki pages in one ingest
  - resolving a material contradiction
  - overwriting existing page structure
  - moving or renaming existing pages
```

---

## Error Handling

| Condition | Action |
|---|---|
| Source missing | Stop and ask for a valid source path |
| Source outside raw-root | Ask whether to treat it as a one-off external source |
| Wiki starter files missing | Run or recommend llm-wiki-bootstrap first |
| Source too large for one pass | Propose chunked ingest with a source summary draft |
| Contradiction detected | Follow contradiction-policy; default ask-before-update |
| Unexpected failure | Stop. Write error to bus. Notify user. |
