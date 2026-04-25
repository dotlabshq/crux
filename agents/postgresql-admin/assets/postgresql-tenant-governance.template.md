# PostgreSQL Tenant Governance

This template is the source material for `.crux/docs/postgresql-tenant-governance.md`.
Use it when `postgresql-admin` needs a baseline for tenant naming, role boundaries, and schema/database allocation.

---

## Core Position

Tenant resources should be predictable, least-privilege, and easy to audit.

---

## Review Areas

- tenant naming pattern
- schema-per-tenant or database-per-tenant model
- role naming pattern
- default privileges
- read-only access model
- production-sensitive tenant handling

---

## Output Pattern

Summarise:
- current isolation model
- naming consistency
- privilege posture
- cleanup or standardisation actions
