---
name: workflow-simplifier
description: >
  Reduces a bloated process into a smaller, clearer operating workflow with fewer
  moving parts and better decision points. Use when: a team process is too heavy,
  responsibilities are blurred, approvals create friction, or the user wants a
  practical "what should we actually do" version of the workflow.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# workflow-simplifier

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Simplifies a process into a leaner flow with clear decision points, owners, and a smaller execution surface.

---

## When to Use Me

- A process has too many steps or approvals
- Teams are confused about who owns what
- The user wants the simplest workable operating model

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/decision-framing-patterns.md  (generate from agent assets first if missing)

Estimated token cost: ~300 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `current-workflow` | user | Yes |
| `pain-points` | user | No |
| `constraints` | user | No |

---

## Steps

```
1. Identify the workflow goal
2. Remove non-essential steps, duplicated approvals, and unclear ownership
3. Rebuild the workflow around only the critical decision points
4. Assign a simple owner map
5. Return a lean version and explain what was intentionally removed
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Simplified Workflow

## Goal
- ...

## Lean Flow
1. ...
2. ...
3. ...

## What Was Removed
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Workflow goal is unclear | clarify the intended outcome before simplifying |
| Constraints prevent simplification | return the smallest safe reduction instead |
| Unexpected failure | Stop. Write error to bus. Notify user. |
