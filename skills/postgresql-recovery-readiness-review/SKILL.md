---
name: postgresql-recovery-readiness-review
description: >
  Evaluates whether PostgreSQL backup posture is actually recoverable in practice.
  Use when: the user asks if recovery is realistic, RPO/RTO readiness needs review,
  restore evidence is unclear, or backup status alone is not enough for confidence.
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-only
  approval: No
---

# postgresql-recovery-readiness-review

**Owner**: `postgresql-admin`
**Type**: `read-only`
**Approval**: `No`

## What I Do

Turns backup and restore evidence into a practical PostgreSQL recovery-readiness judgment.

## When to Use Me

- restore preparedness review
- RPO/RTO discussion
- backup exists but recovery confidence is unclear

## Context Requirements

```
Requires already loaded:
  .crux/agents/postgresql-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/postgresql-backup-recovery-baseline.md
  (generate from agent assets first if missing)
```

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user / MEMORY.md | Yes |
| `backup-context` | MEMORY.md / user | No |

## Steps

```
1. Review available backup and WAL evidence
2. Review restore path and test evidence if any
3. Assess recovery confidence against known expectations
4. Return practical readiness summary and gaps
5. Skill complete — unload
```

## Output

Inline markdown summary.

## Error Handling

| Condition | Action |
|---|---|
| Restore evidence absent | mark readiness as unproven |
| Inputs are partial | state confidence accordingly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
