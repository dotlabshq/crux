# MySQL Operations Principles

This template is the source material for `.crux/docs/mysql-operations-principles.md`.
Use it when `mysql-admin` needs a clear operational baseline.

---

## Core Position

MySQL and MariaDB operations should be explicit, scoped, and verified after change.

Default posture:
- inspect before mutating
- keep database and user scope explicit
- treat production databases conservatively
- verify replication, backup, and privilege posture separately

---

## Operational Priorities

- know server role
- know database inventory
- know user and grant shape
- know backup freshness
- know whether recovery is believable

---

## Output Expectations

Preferred outputs:
- schema overview
- backup posture note
- replication note
- access governance note
- recovery readiness summary
