---
name: frontend-doc-writer
description: >
  Writes short frontend documentation, UI notes, or architecture summaries. Use
  when: the user wants frontend docs, component notes, state-flow notes, or a
  markdown summary of frontend structure or behaviour.
license: MIT
compatibility: opencode
metadata:
  owner: frontend-developer
  type: read-write
  approval: No
---

# frontend-doc-writer

**Owner**: `frontend-developer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces concise frontend markdown docs that are useful for future UI work.

---

## When to Use Me

- User asks for frontend docs or summaries
- A frontend change should leave a concise note behind
- Component or state behaviour should be documented

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/frontend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/frontend-development-principles.md (generate from agent assets first if missing)
  .crux/docs/frontend.md                        (generate via ui-structure-analyser if missing and needed)

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
1. Determine the smallest useful frontend note
2. Write a concise markdown document or update
3. Keep it short, component-specific, and future-useful
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
| No target path given | Propose a sensible frontend doc location first |
| Requested doc is too broad | Narrow it to the current frontend scope |
| Unexpected failure | Stop. Write error to bus. Notify user. |
