---
name: api-surface-analyser
description: >
  Analyses backend API shape, routes, handlers, service boundaries, and contract
  surfaces. Use when: the user asks how the backend is structured, wants an API
  review, or needs contract-sensitive areas identified before a change.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-only
  approval: No
---

# api-surface-analyser

**Owner**: `backend-developer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Maps backend API surfaces and service boundaries before implementation or review.

---

## When to Use Me

- User asks about API structure or backend boundaries
- A contract-sensitive change is being planned
- Backend architecture needs targeted analysis instead of a full scan

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/backend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/api-contract-guidelines.md        (generate from agent assets first if missing)
  .crux/docs/backend-development-principles.md (generate from agent assets first if missing)
  .crux/docs/backend.md                        (generate via codebase-scanner if missing and needed)

Estimated token cost: ~400 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-area` | user | No |
| `question` | user | No |

---

## Steps

```
1. Identify the relevant backend entry points, handlers, routes, or services
2. Trace the likely contract surface and dependent areas
3. Summarise structure, risk points, and likely change scope
4. Return a concise backend surface analysis
5. Skill complete — unload
```

---

## Output

Delivered inline. Format: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Surface cannot be located quickly | Return best-effort candidate areas and note uncertainty |
| Backend architecture doc missing | Suggest or trigger a broader architecture scan |
| Unexpected failure | Stop. Write error to bus. Notify user. |
