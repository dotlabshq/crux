---
name: backend-test-writer
description: >
  Writes or improves backend tests for changed behaviour, service boundaries,
  and risky logic. Use when: the user asks for backend tests, when coverage is
  weak around a change, or when validation is needed before review.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-write
  approval: No
---

# backend-test-writer

**Owner**: `backend-developer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Adds backend tests or proposes a precise backend test plan for changed behaviour.

---

## When to Use Me

- User asks for backend tests
- A backend feature or fix needs validation
- Coverage is weak around changed backend logic

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/backend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/backend-testing-strategy.md       (generate from agent assets first if missing)
  .crux/docs/schema-safety-guidelines.md       (generate from agent assets first if missing)
  .crux/docs/backend.md                        (generate via codebase-scanner if missing and needed)

Estimated token cost: ~400 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `changed-area` | user / implementation analysis | Yes |
| `test-goal` | user | No |

---

## Steps

```
1. Read the changed backend behaviour and existing test patterns
2. Decide the smallest meaningful test layer
3. Add or update tests conservatively
4. Note remaining gaps if full validation is not practical
5. Return a short test summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `backend test files as needed`
**Format**: `source files`

---

## Error Handling

| Condition | Action |
|---|---|
| No clear test seam exists | Return a focused test plan and explain constraints |
| Existing tests are highly fragile | Minimise blast radius and note risk |
| Unexpected failure | Stop. Write error to bus. Notify user. |
