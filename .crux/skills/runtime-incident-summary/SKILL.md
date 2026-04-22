---
name: runtime-incident-summary
description: >
  Writes a short runtime incident summary with timeline, impact, likely platform
  factors, and follow-up notes. Use when: the user wants an incident summary,
  post-incident platform note, or a concise runtime follow-up record.
license: MIT
compatibility: opencode
metadata:
  owner: platform-engineer
  type: read-write
  approval: No
---

# runtime-incident-summary

**Owner**: `platform-engineer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces a concise runtime incident summary that is useful for follow-up rather than blame.

---

## When to Use Me

- User wants a runtime incident summary
- A platform incident needs a short markdown record
- Follow-up actions should be captured after an outage or degraded event

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/platform-engineer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/platform-principles.md          (generate from agent assets first if missing)
  .crux/docs/observability-guidelines.md     (generate from agent assets first if missing)

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `incident-context` | user | Yes |
| `target-path` | user | No |

---

## Steps

```
1. Summarise timeline, impact, and likely platform factors
2. Distinguish observed facts from assumptions
3. Add follow-up and visibility gaps clearly
4. Write a short incident note if requested
5. Return a concise summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `target markdown path as requested`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Incident context is incomplete | Write a partial summary and mark missing facts |
| Root cause is unknown | Keep the note factual and avoid overclaiming |
| Unexpected failure | Stop. Write error to bus. Notify user. |
