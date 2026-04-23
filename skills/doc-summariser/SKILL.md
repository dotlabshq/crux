---
name: doc-summariser
description: >
  Generates or regenerates a token-efficient summary of a docs/ file
  and writes it to the matching summaries/ path.
  Use when: (1) a docs/ file is created or significantly updated,
  (2) summaries/{doc}.md is missing,
  (3) MANIFEST.md shows summary as missing for a doc,
  (4) agent is about to load a full doc but summary would suffice.
license: MIT
compatibility: opencode
metadata:
  owner: coordinator
  type: read-write
  approval: "No"
---

# doc-summariser

**Owner**: `coordinator`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Reads a `.crux/docs/{topic}.md` file, produces a concise summary
(max 200 tokens), and writes it to `.crux/summaries/{topic}.md`.
Updates the MANIFEST.md docs table with the summary path and estimated
token count for the full doc.

---

## When to Use Me

- A new docs/ file was just created by any skill
- `summaries/{topic}.md` is missing and an agent needs context
- MANIFEST.md shows `summary: missing` for a doc
- Any docs/ file is updated — regenerate its summary

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/MANIFEST.md   (to update docs table)

Loads during execution:
  .crux/docs/{topic}.md         (the doc to summarise)

Estimated token cost: ~300 tokens + doc size (doc unloaded after use)
Unloaded after: summaries/{topic}.md written and MANIFEST.md updated
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `topic` | caller (skill or coordinator) — filename without `.md` | Yes |
| `docs/{topic}.md` | `.crux/docs/` | Yes |

---

## Steps

```
Step 1 — Verify source exists
  Check .crux/docs/{topic}.md
  IF not found → stop, notify:
    "docs/{topic}.md not found. Cannot summarise."

Step 2 — Estimate token count
  Read file. Count approximate tokens (chars / 4).
  IF file is already under 300 tokens:
    → skip summary, notify: "Doc is small enough to load directly."
    → update MANIFEST.md: summary: not-needed
    → done

Step 3 — Generate summary
  Read full doc content.
  Write a summary following these rules:
    - Max 200 tokens (hard limit)
    - Lead with: what this doc describes (one sentence)
    - Cover: key facts, values, names — anything an agent needs
      to decide whether to load the full doc
    - No filler, no headers, no lists — dense prose or key: value pairs
    - End with: "Last updated: {DATE}"

Step 4 — Create summaries/ if needed
  IF .crux/summaries/ does not exist → create it

Step 5 — Write .crux/summaries/{topic}.md

Step 6 — Update MANIFEST.md docs table:
  summary:       .crux/summaries/{topic}.md
  tokens (est.): {estimated token count of full doc}
  last-updated:  {DATE}

Step 7 — Skill complete
  Notify: "Summary written to .crux/summaries/{topic}.md"
```

---

## Output

**Writes to**: `.crux/summaries/{topic}.md`
**Format**: dense markdown — no headers unless doc has distinct sections

### Summary format

```markdown
# {Topic} — Summary

{One sentence: what this doc describes.}
{Key facts as prose or key: value pairs — max 200 tokens total.}

Last updated: {DATE} — source: {docs/{topic}.md}
```

---

## Batch Mode

When called without a specific topic (e.g. after installation or bulk doc generation):

```
1. Read MANIFEST.md docs table
2. For each row where summary is "missing":
   → run Steps 1–6 for that doc
3. Report: "Summaries generated for: {list}"
```

---

## Error Handling

| Condition | Action |
|---|---|
| `docs/{topic}.md` not found | Stop. Notify caller. |
| `summaries/` not writable | Write to `workspace/output/summaries/`. Notify user. |
| Doc already has a recent summary | Skip. Report: "Summary up to date." |