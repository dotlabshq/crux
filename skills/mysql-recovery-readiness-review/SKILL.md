---
name: mysql-recovery-readiness-review
description: >
  Evaluates whether MySQL or MariaDB backup posture is actually recoverable in practice.
  Use when: the user asks if recovery is realistic, RPO/RTO readiness needs review,
  or backup evidence exists but restore confidence is weak.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-only
  approval: No
---

# mysql-recovery-readiness-review

**Owner**: `mysql-admin`
**Type**: `read-only`
**Approval**: `No`

## What I Do

Turns backup and restore evidence into a practical MySQL recovery-readiness judgment.

## When to Use Me

- restore preparedness review
- RPO/RTO discussion
- backup exists but recovery confidence is unclear

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/mysql-backup-recovery-baseline.md
  (generate from agent assets first if missing)
```

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user / MEMORY.md | Yes |

## Steps

```
1. Review available backup and binlog evidence
2. Review restore path and test evidence if any
3. Assess recovery confidence
4. Return readiness summary and gaps
5. Skill complete — unload
```

## Output

Inline markdown summary.

## Error Handling

| Condition | Action |
|---|---|
| Restore evidence absent | mark readiness as unproven |
| Unexpected failure | Stop. Write error to bus. Notify user. |
