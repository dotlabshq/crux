# PostgreSQL Operations Principles

This template is the source material for `.crux/docs/postgresql-operations-principles.md`.
Use it when `postgresql-admin` needs a clear operational baseline.

---

## Core Position

Database operations should be explicit, reversible where possible, and evidence-based.

Default posture:
- inspect before mutating
- prefer narrow scope over broad change
- verify after any meaningful action
- separate schema work, user access work, backup work, and recovery work

---

## Operational Priorities

- know primary vs replica role
- know backup freshness
- know privilege boundaries
- know recovery expectations
- know which databases are production-sensitive

---

## Change Discipline

For any database mutation:
1. identify database, schema, role, and object scope
2. show exact SQL
3. explain impact
4. gate through approval when required
5. verify resulting state

---

## Output Expectations

Preferred outputs:
- schema overview
- backup posture note
- replication posture note
- privilege change plan
- recovery readiness summary
