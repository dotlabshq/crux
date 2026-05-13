---
name: llm-wiki-schema-evolver
description: >
  Evolves the LLM Wiki schema when the user's domain needs new page types,
  frontmatter fields, output formats, naming rules, or workflow changes.
  Use when: repeated wiki work no longer fits the current schema, the user asks
  to customize the LLM Wiki, or new domain-specific categories are needed.
license: MIT
compatibility: opencode
metadata:
  owner: llm-wiki
  type: read-write
  approval: "Yes before changing schema guidance or migrating pages"
---

# llm-wiki-schema-evolver

**Owner**: `llm-wiki`
**Type**: `read-write`
**Approval**: `Yes before changing schema guidance or migrating pages`

---

## What I Do

Proposes and applies small schema changes so the wiki fits the user's actual
domain without losing consistency, provenance, or navigation quality.

---

## When to Use Me

- User wants to customize page types or output formats
- Existing categories do not fit repeated content
- Ingest or query work keeps producing the same awkward structure
- New frontmatter fields, directories, or naming rules are needed
- A domain-specific wiki convention should become durable

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/llm-wiki/MEMORY.md

Loads during execution (lazy):
  .crux/docs/llm-wiki-schema.md
  {framework-home}/agents/llm-wiki/assets/llm-wiki-schema.template.md if base template is needed
  {wiki-root}/index.md
  {wiki-root}/glossary.md if terminology changes
  representative pages affected by the schema change

Estimated token cost: ~800 tokens + affected examples
Unloaded after: schema proposal or approved schema update complete
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `schema-change-request` | user / repeated task evidence | Yes |
| `wiki-root` | MEMORY.md / user | No — default: `wiki/` |
| `migration-policy` | user | No — default: propose before migrating |

---

## Steps

```
1. Identify schema pressure
   Explain what does not fit:
     - page type gap
     - output format gap
     - frontmatter gap
     - naming or link convention gap
     - workflow gap

2. Inspect current schema and examples
   Read .crux/docs/llm-wiki-schema.md.
   Read index.md and representative pages.

3. Propose smallest useful change
   Include:
     - new or changed rule
     - directory impact
     - frontmatter impact
     - affected existing pages
     - migration need, if any

4. Approval gate
   Ask before changing schema guidance or migrating pages.

5. Apply approved schema change
   Update .crux/docs/llm-wiki-schema.md.
   Create new directory if needed.
   Update index.md section headings if needed.
   Migrate pages only if explicitly approved.

6. Append schema log entry
   Format: ## [YYYY-MM-DD] schema | {Change Summary}

7. Return change summary and any follow-up migration tasks.
```

---

## Output

**Writes to**: `.crux/docs/llm-wiki-schema.md`, optional `{wiki-root}/index.md`, optional `{wiki-root}/log.md`, optional new wiki directories or migrated pages
**Format**: `markdown`

### Schema proposal format

```markdown
# LLM Wiki Schema Change Proposal

## Problem

## Proposed Change

## Affected Paths

## Migration Impact

## Approval Needed
```

### Log entry format

```markdown
## [YYYY-MM-DD] schema | {Change Summary}

Change: ...
Reason: ...
Affected paths: ...
Migration: applied/skipped/not needed
```

---

## Approval Gate

```
Before changing schema or migrating pages:

1. Show exact schema sections and paths to update
2. List affected page types and existing pages
3. Explain whether this is reversible
4. Wait for explicit approval
5. Apply only the approved change
```

---

## Error Handling

| Condition | Action |
|---|---|
| Requested schema change is one-off content | Recommend normal analysis page instead |
| Change conflicts with provenance rules | Reject or propose a safer alternative |
| Existing pages need migration | Ask before any migration |
| Schema file missing | Generate it with llm-wiki-bootstrap first |
| Unexpected failure | Stop. Write error to bus. Notify user. |
