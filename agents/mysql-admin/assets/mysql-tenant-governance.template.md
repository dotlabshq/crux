# MySQL Tenant Governance

This template is the source material for `.crux/docs/mysql-tenant-governance.md`.
Use it when `mysql-admin` needs a baseline for tenant naming, database allocation, and grant boundaries.

---

## Core Position

Tenant resources should be predictable, least-privilege, and easy to reason about.

---

## Review Areas

- database naming pattern
- table-prefix approach if used
- user naming pattern
- host-scoped grants
- read-only model
- production-sensitive tenant handling

---

## Output Pattern

Summarise:
- current tenant model
- naming consistency
- grant posture
- cleanup or standardisation actions
