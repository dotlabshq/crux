---
name: observability-check
description: >
  Reviews logging, metrics, traces, dashboards, alerts, and runtime visibility
  gaps. Use when: the user asks about observability, runtime signals, or what is
  missing to understand incidents faster.
license: MIT
compatibility: opencode
metadata:
  owner: platform-engineer
  type: read-only
  approval: No
---

# observability-check

**Owner**: `platform-engineer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Evaluates runtime visibility and reports useful observability gaps without pretending signals exist.

---

## When to Use Me

- User asks about logs, metrics, traces, dashboards, or alerts
- An incident was hard to explain and visibility is in question
- Platform review needs observability context first

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/platform-engineer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/observability-guidelines.md   (generate from agent assets first if missing)
  .crux/docs/platform.md                   (generate during onboarding if missing and needed)

Estimated token cost: ~300 tokens
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
1. Identify configured observability signals and likely gaps
2. Summarise what is visible and what is not
3. Return a concise observability note with follow-up suggestions
4. Skill complete — unload
```

---

## Output

Delivered inline. Format: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Signal sources are unclear | Return best-effort findings and mark uncertainty |
| No obvious observability config found | State that clearly and suggest next checks |
| Unexpected failure | Stop. Write error to bus. Notify user. |
