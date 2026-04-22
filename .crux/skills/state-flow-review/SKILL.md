---
name: state-flow-review
description: >
  Reviews state ownership, props flow, stores, hooks, and interaction-heavy UI
  paths before a risky change lands. Use when: the user touches shared state,
  providers, stores, hook-heavy areas, or cross-component interaction flow.
license: MIT
compatibility: opencode
metadata:
  owner: frontend-developer
  type: read-only
  approval: No
---

# state-flow-review

**Owner**: `frontend-developer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Highlights state and interaction risk before frontend implementation or approval.

---

## When to Use Me

- A change touches shared state or providers
- The user asks whether a frontend change is risky
- State ownership or interaction flow is unclear

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/frontend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/state-flow-guidelines.md           (generate from agent assets first if missing)
  .crux/docs/component-structure-guidelines.md  (generate from agent assets first if missing)

Estimated token cost: ~300 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `change-scope` | user / diff / analysis | Yes |

---

## Steps

```
1. Identify stateful surfaces touched by the change
2. Trace likely readers, writers, and interaction fallout
3. Summarise state-flow risk and follow-up needs
4. Return a state-flow review note
5. Skill complete — unload
```

---

## Output

Delivered inline. Format: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Scope is unclear | Request narrower paths or describe likely state risks only |
| No major shared state found | Return a short "no major state-flow risk detected" note |
| Unexpected failure | Stop. Write error to bus. Notify user. |
