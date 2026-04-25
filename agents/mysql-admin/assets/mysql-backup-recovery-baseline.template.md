# MySQL Backup And Recovery Baseline

This template is the source material for `.crux/docs/mysql-backup-recovery-baseline.md`.
Use it when `mysql-admin` reviews backup posture or restore preparedness.

---

## Review Areas

- dump or physical backup mechanism
- backup freshness
- binary log retention where relevant
- replica usefulness for recovery posture
- documented restore path
- tested restore evidence
- stated RPO / RTO if known

---

## Core Position

Backups are not enough unless restore readiness is also credible.

Review should separate:
- backup existence
- backup freshness
- recovery practicality

---

## Output Pattern

Summarise:
- what backup evidence exists
- what recovery evidence exists
- what remains unknown
- what should be tested next
