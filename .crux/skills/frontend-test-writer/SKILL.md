---
name: frontend-test-writer
description: >
  Writes or improves frontend tests for changed UI behaviour, interaction flow,
  or component state. Use when: the user asks for frontend tests, when coverage
  is weak around a UI change, or when validation is needed before review.
license: MIT
compatibility: opencode
metadata:
  owner: frontend-developer
  type: read-write
  approval: No
---

# frontend-test-writer

**Owner**: `frontend-developer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Adds frontend tests or proposes a precise UI test plan for changed behaviour.

---

## When to Use Me

- User asks for frontend tests
- A UI feature or fix needs validation
- Coverage is weak around changed interaction behaviour

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/frontend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/frontend-testing-strategy.md       (generate from agent assets first if missing)
  .crux/docs/state-flow-guidelines.md           (generate from agent assets first if missing)
  .crux/docs/frontend.md                        (generate via ui-structure-analyser if missing and needed)

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
1. Read the changed frontend behaviour and existing test patterns
2. Decide the smallest meaningful test layer
3. Add or update tests conservatively
4. Note remaining UI risk if full validation is not practical
5. Return a short test summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `frontend test files as needed`
**Format**: `source files`

---

## Error Handling

| Condition | Action |
|---|---|
| No clear test seam exists | Return a focused test plan and explain constraints |
| Existing tests are highly fragile | Minimise blast radius and note risk |
| Unexpected failure | Stop. Write error to bus. Notify user. |
