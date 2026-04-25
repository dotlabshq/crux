---
name: mysql-user-access-governance
description: >
  Reviews or plans MySQL/MariaDB user, authentication, and grant changes with
  least-privilege discipline. Use when: the user wants to inspect access posture,
  plan grants/revokes, review broad permissions, or manage database access
  outside tenant provisioning.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-write
  approval: Yes
---

# mysql-user-access-governance

**Owner**: `mysql-admin`
**Type**: `read-write`
**Approval**: `Yes`

## What I Do

Handles MySQL/MariaDB user and grant governance outside tenant provisioning, with explicit least-privilege review.

## When to Use Me

- user or grant review
- access cleanup
- grant/revoke planning

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/mysql-tenant-governance.md
  (generate from agent assets first if missing)
```

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-database` | user | Yes |
| `operation` | user | Yes — review / create-user / grant / revoke / cleanup |

## Steps

```
1. Inspect current user and grant posture
2. Produce the narrowest acceptable privilege plan
3. Present exact SQL and impact
4. Wait for approval before mutating
5. Skill complete — unload
```

## Output

Inline markdown summary.

## Error Handling

| Condition | Action |
|---|---|
| Privilege scope too broad | present narrower alternative |
| Unexpected failure | Stop. Write error to bus. Notify user. |
