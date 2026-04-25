---
name: mysql-schema-analyser
description: >
  Analyses a MySQL or MariaDB instance and produces a database architecture and
  schema overview. Use when: `.crux/docs/mysql.md` is missing, onboarding needs
  a live schema scan, or the user wants a concise MySQL topology and object
  inventory summary.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-write
  approval: No
---

# mysql-schema-analyser

**Owner**: `mysql-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Builds a read-only overview of MySQL/MariaDB databases, schemas, and key operational traits.

---

## When to Use Me

- `.crux/docs/mysql.md` is missing
- onboarding requires database inventory
- user asks for MySQL schema/topology overview

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/AGENT.md
  .crux/workspace/mysql-admin/MEMORY.md

External requirement:
  mysql client access to the target instance

Estimated token cost: ~700 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user / MEMORY.md | Yes |
| `target-port` | user / MEMORY.md | No |
| `target-user` | user / MEMORY.md | No |

---

## Steps

```
1. Validate connection
2. Collect version, database inventory, table counts, and replication role if visible
3. Summarise schema shape and notable operational traits
4. Write docs/mysql.md
5. Return concise result summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `.crux/docs/mysql.md`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| mysql client not found | Stop. Notify user. |
| Connection fails | Stop. Record blocker in notes. |
| `.crux/docs/` not writable | Write to `.crux/workspace/mysql-admin/output/` and notify user |
