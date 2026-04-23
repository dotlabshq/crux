---
name: backend-doc-writer
description: >
  Writes short backend documentation, architecture notes, contract notes, or
  change summaries. Use when: the user wants backend docs, implementation notes,
  or a markdown summary of backend structure or behaviour.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-write
  approval: No
---

# backend-doc-writer

**Owner**: `backend-developer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces concise backend markdown docs that are useful for future backend work.

---

## When to Use Me

- User asks for backend docs or summaries
- A backend change should leave a concise note behind
- Contract or implementation behaviour should be documented

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/backend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/backend-development-principles.md (generate from agent assets first if missing)
  .crux/docs/backend.md                        (generate via codebase-scanner if missing and needed)

Estimated token cost: ~300 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `doc-purpose` | user | Yes |
| `target-path` | user | No |

---

## Steps

```
1. Determine the smallest useful backend note
2. Write a concise markdown document or update
3. Keep it short, path-specific, and future-useful
4. Return a doc summary
5. Skill complete — unload
```

---

## Output

**Writes to**: `target markdown path as requested`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| No target path given | Propose a sensible backend doc location first |
| Requested doc is too broad | Narrow it to the current backend scope |
| Unexpected failure | Stop. Write error to bus. Notify user. |
