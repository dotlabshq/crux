---
name: mysql-replication-review
description: >
  Reviews MySQL or MariaDB replication posture, lag, and role state. Use when:
  replication health is questioned, lag needs interpretation, or the user wants
  a concise summary of primary/replica status before operational action.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-only
  approval: No
---

# mysql-replication-review

**Owner**: `mysql-admin`
**Type**: `read-only`
**Approval**: `No`

## What I Do

Builds a concise MySQL/MariaDB replication health view from live replication evidence.

## When to Use Me

- replication lag review
- primary/replica posture review
- failover readiness discussion

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/mysql-operations-principles.md
  (generate from agent assets first if missing)
```

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user / MEMORY.md | Yes |

## Steps

```
1. Confirm connection and role
2. Inspect replication status and lag evidence
3. Identify healthy / warning / critical posture
4. Return concise replication summary
5. Skill complete — unload
```

## Output

Inline markdown summary.

## Error Handling

| Condition | Action |
|---|---|
| Replication status unavailable | report topology evidence gap |
| Unexpected failure | Stop. Write error to bus. Notify user. |
