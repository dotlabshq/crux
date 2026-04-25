---
name: postgresql-replication-review
description: >
  Reviews PostgreSQL replication posture, lag, sender/receiver state, and failover
  risk. Use when: replication health is questioned, lag needs interpretation, a
  primary/replica topology should be reviewed, or the user wants a concise
  replication status summary before operational action.
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-only
  approval: No
---

# postgresql-replication-review

**Owner**: `postgresql-admin`
**Type**: `read-only`
**Approval**: `No`

## What I Do

Builds a concise PostgreSQL replication health view from live replication evidence.

## When to Use Me

- replication lag review
- primary/replica posture review
- failover readiness discussion

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
| `target-port` | user / MEMORY.md | No |

## Steps

```
1. Confirm connection and role
2. Inspect replication views and lag indicators
3. Identify healthy / warning / critical posture
4. Summarise operational risk and next action
5. Skill complete — unload
```

## Output

Inline markdown summary.

## Error Handling

| Condition | Action |
|---|---|
| Replication view unavailable | report topology evidence gap |
| Lag signal unclear | state uncertainty explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
