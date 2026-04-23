---
name: component-implementation
description: >
  Implements or refactors frontend components and UI behaviour while respecting
  local structure, shared UI patterns, and state boundaries. Use when: the user
  wants a UI feature, a component change, or a frontend bug fix.
license: MIT
compatibility: opencode
metadata:
  owner: frontend-developer
  type: read-write
  approval: No
---

# component-implementation

**Owner**: `frontend-developer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Guides frontend implementation work with attention to shared UI and interaction safety.

---

## When to Use Me

- User wants a frontend feature implemented
- A UI bug should be fixed
- A component should be refactored

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/frontend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/frontend-development-principles.md (generate from agent assets first if missing)
  .crux/docs/component-structure-guidelines.md  (generate from agent assets first if missing)
  .crux/docs/frontend.md                        (generate via ui-structure-analyser if missing and needed)

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
1. Read the relevant frontend area and local patterns
2. Identify shared UI, route, and state implications
3. Implement or refactor conservatively
4. Flag test needs and state-flow concerns explicitly
5. Return implementation summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `frontend code and related UI files as needed`
**Format**: `source files`

---

## Error Handling

| Condition | Action |
|---|---|
| Target area unclear | Ask for clarification or narrow candidate component paths |
| Shared UI risk detected | Surface risk before broad edits |
| Unexpected failure | Stop. Write error to bus. Notify user. |
