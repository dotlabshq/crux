---
name: board-security-update
description: >
  Prepares a board-level or senior-management security update that highlights
  status, key risks, decisions, and ownership without operational noise. Use
  when: a board pack note is needed, senior management wants a security update,
  or a quarterly status message must be made decision-oriented.
license: MIT
compatibility: opencode
metadata:
  owner: ciso-advisor
  type: read-write
  approval: No
---

# board-security-update

**Owner**: `ciso-advisor`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turn multiple security inputs into a board-appropriate update focused on risk posture, material movements, and required decisions.

---

## When to Use Me

- Board update is requested
- Senior management wants a concise security status note
- Quarterly or monthly cyber reporting should be executive-ready

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ciso-advisor/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ciso-communication-principles.md
  .crux/docs/risk-framing-patterns.md

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `security-status` | user / prior outputs | Yes |
| `reporting-period` | user | No |

---

## Steps

```
1. Extract the period's important security movements
2. Ignore low-value operational detail
3. Highlight risk, trend, ownership, and decision need
4. Keep tone board-appropriate and brief
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Inputs are too operational | Compress to material items only |
| No decision is needed | State status and next watchpoint only |
| Unexpected failure | Stop. Write error to bus. Notify user. |
