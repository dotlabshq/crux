---
name: service-implementation
description: >
  Implements or refactors backend service logic while respecting existing service
  boundaries, contracts, and local patterns. Use when: the user wants backend
  feature work, a server-side bug fix, or backend refactoring.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-write
  approval: No
---

# service-implementation

**Owner**: `backend-developer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Guides backend implementation work with explicit attention to local patterns and contract safety.

---

## When to Use Me

- User wants a backend feature implemented
- A backend bug should be fixed
- Backend refactoring is requested

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/backend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/backend-development-principles.md (generate from agent assets first if missing)
  .crux/docs/api-contract-guidelines.md        (generate from agent assets first if missing)
  .crux/docs/backend.md                        (generate via codebase-scanner if missing and needed)

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `change-request` | user | Yes |
| `target-area` | user / analysis | No |

---

## Steps

```
1. Read the relevant backend area and local patterns
2. Identify service boundary and contract implications
3. Implement or refactor conservatively
4. Flag test needs and schema-sensitive concerns explicitly
5. Return implementation summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `code and related backend files as needed`
**Format**: `source files`

---

## Error Handling

| Condition | Action |
|---|---|
| Target area unclear | Ask for clarification or narrow the candidate paths |
| Contract risk detected | Surface risk before proceeding |
| Unexpected failure | Stop. Write error to bus. Notify user. |
