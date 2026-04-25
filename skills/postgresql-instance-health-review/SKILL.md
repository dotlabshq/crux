---
name: postgresql-instance-health-review
description: >
  Reviews PostgreSQL instance-level health signals such as connections, settings,
  extension posture, and operational pressure. Use when: the user wants a broad
  database instance health check, config posture review, or an explanation of
  whether the database looks stable enough before deeper tuning work.
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-only
  approval: No
---

# postgresql-instance-health-review

**Owner**: `postgresql-admin`
**Type**: `read-only`
**Approval**: `No`

## What I Do

Summarises PostgreSQL instance posture beyond one query or one table.

## When to Use Me

- broad instance health review
- config posture discussion
- connection pressure review

## Context Requirements

```
Requires already loaded:
  .crux/agents/postgresql-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/postgresql-operations-principles.md
  (generate from agent assets first if missing)
```

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user / MEMORY.md | Yes |
| `target-database` | user | No |

## Steps

```
1. Inspect broad instance signals
2. Identify pressure, risk, or drift
3. Return a concise instance health note
4. Skill complete — unload
```

## Output

Inline markdown summary.

## Error Handling

| Condition | Action |
|---|---|
| Evidence is partial | mark unknowns explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
