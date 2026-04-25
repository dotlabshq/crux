---
name: postgresql-user-access-governance
description: >
  Reviews or plans PostgreSQL role, login, and privilege changes with least-privilege
  discipline. Use when: the user wants to inspect role posture, plan grants/revokes,
  review broad permissions, or manage database access outside tenant provisioning.
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-write
  approval: Yes
---

# postgresql-user-access-governance

**Owner**: `postgresql-admin`
**Type**: `read-write`
**Approval**: `Yes`

## What I Do

Handles PostgreSQL role and privilege governance outside tenant provisioning, with explicit least-privilege review.

## When to Use Me

- role or grant review
- user access cleanup
- grant/revoke planning

## Context Requirements

```
Requires already loaded:
  .crux/agents/postgresql-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/postgresql-tenant-governance.md
  (generate from agent assets first if missing)
```

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-database` | user | Yes |
| `operation` | user | Yes — review / create-role / grant / revoke / cleanup |
| `role-scope` | user | No |

## Steps

```
1. Inspect current role and privilege posture
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
| Role model unclear | inspect current grants first |
| Unexpected failure | Stop. Write error to bus. Notify user. |
