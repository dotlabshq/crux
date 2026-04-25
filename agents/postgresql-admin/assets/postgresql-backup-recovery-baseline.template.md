# PostgreSQL Backup And Recovery Baseline

This template is the source material for `.crux/docs/postgresql-backup-recovery-baseline.md`.
Use it when `postgresql-admin` reviews backup health or restore preparedness.

---

## Review Areas

- backup tool and schedule
- backup freshness
- WAL archiving health
- retention coverage
- documented restore path
- tested restore evidence
- stated RPO / RTO if known

---

## Core Position

Having backups is not the same as being recoverable.

A healthy posture requires:
- recent backups
- working WAL/archive chain where applicable
- a believable restore path
- confidence that credentials, tooling, and storage are available during an incident

---

## Output Pattern

Summarise:
- what is known
- what is missing
- what is risky
- what should be tested next
