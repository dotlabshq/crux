---
name: mysql-backup-verify
description: >
  Reviews MySQL or MariaDB backup posture, dump strategy, and restore-readiness
  signals. Use when: the user asks whether backups exist, whether backup posture
  is acceptable, or whether MySQL recovery preparedness needs a quick review.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-write
  approval: No
---

# mysql-backup-verify

**Owner**: `mysql-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Evaluates MySQL backup and restore-readiness evidence without performing destructive recovery operations.

---

## When to Use Me

- Backup status is requested
- Restore-readiness should be reviewed
- Operational compliance check includes MySQL backups

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/AGENT.md
  .crux/workspace/mysql-admin/MEMORY.md

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user / MEMORY.md | Yes |
| `backup-tool` | user / MEMORY.md | No |

---

## Steps

```
1. Identify known backup mechanism or detect available evidence
2. Review schedule, freshness, and restore-readiness signals
3. Summarise backup posture and key gaps
4. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Backup tooling unknown | report posture as unknown, not safe |
| Evidence incomplete | mark confidence explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
