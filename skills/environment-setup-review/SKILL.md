---
name: environment-setup-review
description: >
  Reviews environment structure, config boundaries, setup expectations, and
  runtime prerequisites. Use when: the user asks about environments, config
  layout, setup flow, or what is needed to run the system safely.
license: MIT
compatibility: opencode
metadata:
  owner: platform-engineer
  type: read-only
  approval: No
---

# environment-setup-review

**Owner**: `platform-engineer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Maps environment structure and setup expectations before platform changes are made.

---

## When to Use Me

- User asks about local/staging/production setup
- Environment boundaries are unclear
- Platform review needs config context first

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/platform-engineer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/platform-principles.md      (generate from agent assets first if missing)
  .crux/docs/environment-guidelines.md   (generate from agent assets first if missing)
  .crux/docs/platform.md                 (generate during onboarding if missing and needed)

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `scope` | user | No |

---

## Steps

```
1. Identify environment config files and boundaries
2. Summarise setup expectations and risky config surfaces
3. Return a concise environment review
4. Skill complete — unload
```

---

## Output

Delivered inline. Format: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Environment structure is unclear | Return best-effort candidate paths and note uncertainty |
| Config is fragmented | Summarise likely boundaries conservatively |
| Unexpected failure | Stop. Write error to bus. Notify user. |
