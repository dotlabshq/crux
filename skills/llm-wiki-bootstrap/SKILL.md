---
name: llm-wiki-bootstrap
description: >
  Initializes or repairs the starter structure for a private LLM Wiki:
  raw root, wiki root, index, overview, glossary, log, source and analysis
  directories, and schema guidance. Use when: the user asks to create an LLM
  Wiki, configure a Karpathy-style wiki, set up markdown knowledge-base
  scaffolding, or restore missing starter files.
license: MIT
compatibility: opencode
metadata:
  owner: llm-wiki
  type: read-write
  approval: "Yes before creating or overwriting existing wiki files"
---

# llm-wiki-bootstrap

**Owner**: `llm-wiki`
**Type**: `read-write`
**Approval**: `Yes before creating or overwriting existing wiki files`

---

## What I Do

Creates the baseline LLM Wiki structure and starter markdown files while
preserving raw sources and existing wiki content.

---

## When to Use Me

- User asks to initialize or bootstrap an LLM Wiki
- `wiki/index.md`, `wiki/overview.md`, `wiki/glossary.md`, or `wiki/log.md` is missing
- Onboarding needs starter directories and schema guidance
- Existing wiki structure needs a non-destructive repair

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/llm-wiki/MEMORY.md

Loads during execution (lazy):
  agents/llm-wiki/assets/llm-wiki-schema.template.md
  .crux/docs/llm-wiki-schema.md if it exists
  {wiki-root}/index.md if it exists
  {wiki-root}/log.md if it exists

Estimated token cost: ~500 tokens
Unloaded after: starter structure created or repair plan returned
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `raw-root` | user / MEMORY.md | No — default: `raw/` |
| `wiki-root` | user / MEMORY.md | No — default: `wiki/` |
| `wiki-purpose` | user / MEMORY.md | No |
| `page-types` | user / MEMORY.md | No |
| `overwrite-policy` | user | No — default: preserve existing files |

---

## Steps

```
1. Resolve raw-root and wiki-root
   Default raw-root: raw/
   Default wiki-root: wiki/

2. Inspect target paths
   Identify existing files and directories.
   Never modify files under raw-root.

3. Present approval gate before writes
   Include:
     - directories to create
     - files to create
     - files that already exist and will be preserved
     - files that would require explicit overwrite approval

4. Create missing directories
   raw-root/
   wiki-root/
   wiki-root/sources/
   wiki-root/concepts/
   wiki-root/analyses/
   optional page-type directories

5. Create missing starter files
   wiki-root/index.md
   wiki-root/overview.md
   wiki-root/glossary.md
   wiki-root/log.md

6. Generate .crux/docs/llm-wiki-schema.md from agents/llm-wiki/assets/llm-wiki-schema.template.md if missing

7. Append bootstrap entry to wiki-root/log.md if log exists or was created

8. Report created, preserved, skipped, and approval-gated paths
```

---

## Output

**Writes to**: `{wiki-root}/`, `.crux/docs/llm-wiki-schema.md`
**Format**: `markdown`

### Starter `index.md`

```markdown
# Wiki Index

> Master catalog for the LLM Wiki. Read this first.

## Sources

## Concepts

## Analyses

## Products

## Features

## Personas

## Style
```

### Starter `overview.md`

```markdown
# Overview

This wiki has been initialized but has not ingested enough sources for a stable synthesis yet.

## Current Synthesis

## Open Questions

## Knowledge Gaps
```

### Starter `glossary.md`

```markdown
# Glossary

## Canonical Terms

| Term | Definition | Sources | Notes |
|---|---|---|---|

## Deprecated Or Variant Terms

| Term | Prefer | Reason |
|---|---|---|
```

### Starter `log.md`

```markdown
# Wiki Log

## [YYYY-MM-DD] bootstrap | LLM Wiki initialized

Created starter structure for the private LLM Wiki.
```

---

## Approval Gate

```
Before writing files:

1. Present the exact target paths and whether each path is create, preserve, or overwrite
2. State that raw-root is read-only and will not be modified
3. Wait for explicit approval
4. On approval → create missing files and directories
5. On rejection → return the planned structure without writing
```

---

## Error Handling

| Condition | Action |
|---|---|
| Target wiki directory exists and is non-empty | Ask before creating starter files inside it |
| Starter file exists | Preserve by default and report as existing |
| Schema template missing | Stop and notify user |
| Raw root points inside wiki root | Stop and ask user to choose separate roots |
| Unexpected failure | Stop. Write error to bus. Notify user. |
