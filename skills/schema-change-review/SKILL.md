---
name: schema-change-review
description: >
  Reviews backend changes that may affect persistence, migrations, model shape,
  or schema-sensitive contracts. Use when: the user touches database-facing code,
  migrations, ORM models, tenant data, or backward-compatibility sensitive paths.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-only
  approval: No
---

# schema-change-review

**Owner**: `backend-developer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Highlights persistence and schema-related risk before backend implementation or approval.

---

## When to Use Me

- A change touches models, migrations, repositories, or persistence contracts
- The user asks whether a backend change is schema-safe
- Tenant or auth data may be affected

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/backend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/schema-safety-guidelines.md       (generate from agent assets first if missing)
  .crux/docs/api-contract-guidelines.md        (generate from agent assets first if missing)

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
1. Identify persistence-sensitive surfaces touched by the change
2. Check backwards-compatibility, rollout, and contract risks
3. Summarise risk level and follow-up needs
4. Return a schema safety note
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
| No schema-sensitive path found | Return a short "no major schema risk detected" note |
| Unexpected failure | Stop. Write error to bus. Notify user. |
