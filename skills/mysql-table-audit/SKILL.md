---
name: mysql-table-audit
description: >
  Reviews MySQL or MariaDB tables for naming consistency, key structure, and
  basic schema hygiene. Use when: the user wants a MySQL table audit, naming
  check, or a quick review of whether table structure looks disciplined enough
  for ongoing operations.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-write
  approval: No
---

# mysql-table-audit

**Owner**: `mysql-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Performs a read-only MySQL table audit focused on naming, keys, and structural hygiene.

---

## When to Use Me

- User requests table audit
- Naming consistency should be checked
- Schema hygiene needs review

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/AGENT.md
  .crux/workspace/mysql-admin/MEMORY.md

Estimated token cost: ~600 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-database` | user | Yes |
| `table-scope` | user | No |

---

## Steps

```
1. Inspect table inventory and naming patterns
2. Review keys, obvious consistency issues, and structural outliers
3. Summarise findings and likely cleanup priorities
4. Skill complete — unload
```

---

## Output

**Writes to**: `.crux/docs/mysql-table-audit.md` when requested
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Database not found | report scope mismatch |
| Metadata access incomplete | mark audit as partial |
| Unexpected failure | Stop. Write error to bus. Notify user. |
