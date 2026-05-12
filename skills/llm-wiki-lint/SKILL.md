---
name: llm-wiki-lint
description: >
  Health-checks an LLM Wiki for contradictions, stale claims, orphan pages,
  missing cross-references, inconsistent terminology, missing provenance, and
  schema drift. Use when: the user says lint the wiki, health-check the wiki,
  find contradictions, find stale pages, repair links, or review wiki quality.
license: MIT
compatibility: opencode
metadata:
  owner: llm-wiki
  type: read-write
  approval: "No for report; Yes before applying fixes"
---

# llm-wiki-lint

**Owner**: `llm-wiki`
**Type**: `read-write`
**Approval**: `No for report; Yes before applying fixes`

---

## What I Do

Scans the wiki's navigation, terminology, provenance, and link structure, then
reports quality issues and optionally applies approved fixes.

---

## When to Use Me

- User asks to lint or health-check the wiki
- The wiki has had several ingests and needs consistency review
- User suspects contradictions or stale information
- Links, glossary terms, or source provenance need cleanup

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/llm-wiki/MEMORY.md

Loads during execution (lazy):
  .crux/docs/llm-wiki-schema.md
  {wiki-root}/index.md
  {wiki-root}/overview.md
  {wiki-root}/glossary.md
  {wiki-root}/log.md
  wiki pages in scope, batched if needed

Estimated token cost: depends on wiki size; batch when needed
Unloaded after: report written and optional fixes complete
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `scope` | user | No — default: full wiki |
| `apply-fixes` | user | No — default: report only |
| `wiki-root` | MEMORY.md / user | No — default: `wiki/` |

---

## Steps

```
1. Load schema and core files
   Read .crux/docs/llm-wiki-schema.md.
   Read index.md, overview.md, glossary.md, and recent log entries.

2. Build page inventory
   List markdown files under wiki-root.
   Compare actual pages to index.md.

3. Check link health
   Identify:
     - pages missing from index.md
     - index entries pointing to missing pages
     - orphan pages with no inbound links
     - broken wikilinks
     - pages that should link to each other but do not

4. Check provenance
   Identify pages with empty sources where source support is expected.
   Identify source summaries missing raw source path.

5. Check terminology
   Compare page language to glossary canonical terms.
   Flag variants and inconsistent naming.

6. Check freshness and contradictions
   Use updated dates, log order, source summaries, and page status.
   Flag conflicting claims with page paths and short descriptions.

7. Write lint report
   Target: .crux/workspace/llm-wiki/output/lint-reports/{date}-wiki-lint.md

8. If apply-fixes requested
   Present a fix plan and approval gate.
   Apply only approved fixes.
   Update index/log as needed.

9. Append lint entry to wiki-root/log.md
```

---

## Output

**Writes to**: `.crux/workspace/llm-wiki/output/lint-reports/{date}-wiki-lint.md`; optionally `{wiki-root}/**/*.md`, `{wiki-root}/index.md`, `{wiki-root}/glossary.md`, `{wiki-root}/log.md`
**Format**: `markdown`

### Report format

```markdown
# Wiki Lint Report

Generated: YYYY-MM-DD
Scope: {scope}

## Summary

- Pages scanned:
- Issues found:
- Fixes applied:

## Contradictions

| Pages | Issue | Suggested fix |
|---|---|---|

## Stale Claims

| Page | Claim | Newer source/page | Suggested fix |
|---|---|---|---|

## Link Issues

| Page | Issue | Suggested fix |
|---|---|---|

## Terminology Issues

| Term | Page | Glossary guidance | Suggested fix |
|---|---|---|---|

## Provenance Issues

| Page | Issue | Suggested fix |
|---|---|---|

## Open Questions

- ...
```

---

## Approval Gate

```
Before applying fixes:

1. Group fixes by type and affected paths
2. Mark low-risk fixes separately from content-changing fixes
3. Ask which fixes to apply
4. Apply only approved fixes
5. Log fixes applied and skipped
```

---

## Error Handling

| Condition | Action |
|---|---|
| Wiki missing starter files | Recommend llm-wiki-bootstrap |
| Wiki too large for full scan | Batch by page type and report partial scope |
| Contradiction cannot be resolved from sources | Mark as open question; do not rewrite claims |
| Fix would rewrite many pages | Ask for explicit approval and offer staged fixes |
| Unexpected failure | Stop. Write error to bus. Notify user. |
