---
name: deployment-config-review
description: >
  Reviews deployment configuration, rollout-sensitive changes, and release
  readiness before a platform change lands. Use when: the user asks about
  deployment config, release readiness, rollout risk, or deploy-time behaviour.
license: MIT
compatibility: opencode
metadata:
  owner: platform-engineer
  type: read-only
  approval: No
---

# deployment-config-review

**Owner**: `platform-engineer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Highlights rollout and deployment risk before platform implementation or approval.

---

## When to Use Me

- A deploy config change is being planned
- User asks whether a release path is safe
- Rollout behaviour is unclear

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/platform-engineer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/deployment-safety-guidelines.md  (generate from agent assets first if missing)
  .crux/docs/environment-guidelines.md        (generate from agent assets first if missing)

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
1. Identify rollout-sensitive surfaces touched by the change
2. Check environment, release, and rollback implications
3. Summarise deployment safety and follow-up needs
4. Return a deployment review note
5. Skill complete — unload
```

---

## Output

Delivered inline. Format: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Scope is unclear | Request narrower paths or describe likely risk zones only |
| No major rollout-sensitive path found | Return a short "no major deployment risk detected" note |
| Unexpected failure | Stop. Write error to bus. Notify user. |
