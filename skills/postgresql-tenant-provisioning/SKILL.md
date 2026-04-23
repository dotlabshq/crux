---
name: postgresql-tenant-provisioning
description: >
  PostgreSQL-specific step of tenant onboarding. Creates database or schema
  for the tenant (per isolation model), provisions a dedicated role with
  least-privilege access, applies connection limits, and updates docs/db-tenants.md.
  Part of the multi-step tenant onboarding workflow (.crux/workflows/tenant-onboarding.md).
  Use when: PostgreSQL provisioning step of tenant onboarding, or re-applying
  standards to a drifted tenant database/schema (reconcile mode).
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-write
  approval: "Yes — DDL and GRANT statements require user confirmation"
---

# postgresql-tenant-provisioning

**Owner**: `postgresql-admin`
**Type**: `read-write`
**Approval**: `Yes — DDL and GRANT statements require user confirmation`
**Workflow**: Part of `.crux/workflows/tenant-onboarding.md` — Step: PostgreSQL

---

## What I Do

Provisions a fully-configured tenant database or schema:
- Database (database-per-tenant) or schema (schema-per-tenant) with naming convention
- Dedicated role with least-privilege GRANT
- Connection limit on the role
- Optional: separate read-only role for analytics access
- Entry in `docs/db-tenants.md` registry
- Audit log entry to `bus/postgresql-admin/`

---

## When to Use Me

- Coordinator calls this as the PostgreSQL step in the `tenant-onboarding` workflow
- User says: "provision database for {tenant}", "create schema for {tenant}", "add DB access for {tenant}"
- Re-applying standards to an existing tenant database/schema (`--reconcile` mode)

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/postgresql-admin/MEMORY.md
    Fields needed:
      primary-host               (connection target)
      tenant-isolation-model     (schema-per-tenant | database-per-tenant)
      tenant-naming-pattern      (e.g. {tenant-id}_{env})
      production-databases       (for approval gate check)
      postgresql-version         (for feature compatibility)

Does NOT preload docs/db-tenants.md — reads it only when updating.

Estimated token cost: ~350 tokens
Unloaded after: docs/db-tenants.md updated and bus event written
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| tenant-id | workflow / user | Yes |
| environment | workflow / user | Yes |
| owner-email | workflow / user | Yes |
| read-only-role | user | No — creates read-only role if provided |
| reconcile | flag | No — re-applies standards without recreating objects |

**Naming rules**: tenant-id lowercase alphanumeric + underscores only, max 20 chars.
Validated before any SQL runs. (Note: PostgreSQL identifiers use `_` not `-`.)

---

## Steps

```
PRE-FLIGHT

  0. Validate inputs
     tenant-id must match: ^[a-z0-9][a-z0-9_]{0,19}$
     environment must be one of: prod, staging, dev, preview
     IF validation fails → stop, explain the rule, ask user to correct

  1. Derive object name(s) from MEMORY.md → tenant-naming-pattern
     schema-per-tenant:    schema name = {pattern}  e.g. acme_prod
     database-per-tenant:  database name = {pattern}  e.g. app_acme_prod
     role name:            {tenant-id}_{env}_app

  2. Check for existing objects
     IF schema-per-tenant:
       psql ... -c "SELECT schema_name FROM information_schema.schemata
                    WHERE schema_name = '{schema}';"
     IF database-per-tenant:
       psql ... -c "SELECT datname FROM pg_database WHERE datname = '{database}';"
     IF exists AND --reconcile not set → ask user:
       "Object {name} already exists. Run in reconcile mode? (yes / no)"
     IF exists AND --reconcile set → skip to RECONCILE mode

  3. Approval gate
     Present to user:
       "I will provision the following for tenant {tenant-id} ({env}):

        Isolation model: {schema-per-tenant | database-per-tenant}
        Object:   {schema or database name}
        Role:     {role-name} (login, connection limit: 20)
        Grants:   {schema: USAGE, CREATE on schema | database: CONNECT, CREATE}
        {Read-only role: {ro-role-name} (login, SELECT only) | —}

        SQL that will execute:
          {preview of each statement}

        Proceed? (yes / no)"

     Wait for explicit "yes". Do not proceed on ambiguous responses.

PROVISIONING — schema-per-tenant model

  4a. Create schema
      psql ... -c "CREATE SCHEMA IF NOT EXISTS {schema};"

  5a. Create application role
      psql ... -c "CREATE ROLE {role} WITH LOGIN CONNECTION LIMIT 20
                   COMMENT '{tenant-id} application role ({env})';"

  6a. Grant privileges
      psql ... -c "GRANT USAGE, CREATE ON SCHEMA {schema} TO {role};"
      psql ... -c "ALTER DEFAULT PRIVILEGES IN SCHEMA {schema}
                   GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO {role};"
      psql ... -c "ALTER DEFAULT PRIVILEGES IN SCHEMA {schema}
                   GRANT USAGE, SELECT ON SEQUENCES TO {role};"

  7a. Read-only role (if requested)
      psql ... -c "CREATE ROLE {ro-role} WITH LOGIN CONNECTION LIMIT 5
                   COMMENT '{tenant-id} read-only role ({env})';"
      psql ... -c "GRANT USAGE ON SCHEMA {schema} TO {ro-role};"
      psql ... -c "ALTER DEFAULT PRIVILEGES IN SCHEMA {schema}
                   GRANT SELECT ON TABLES TO {ro-role};"

PROVISIONING — database-per-tenant model

  4b. Create database
      psql ... -c "CREATE DATABASE {database}
                   WITH OWNER postgres ENCODING 'UTF8'
                   LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8'
                   TEMPLATE template0;"

  5b. Create application role
      psql ... -c "CREATE ROLE {role} WITH LOGIN CONNECTION LIMIT 20
                   COMMENT '{tenant-id} application role ({env})';"

  6b. Grant privileges
      psql ... -c "GRANT CONNECT, CREATE ON DATABASE {database} TO {role};"
      psql -h {host} -d {database} ... -c "CREATE SCHEMA IF NOT EXISTS app;"
      psql -h {host} -d {database} ... -c "GRANT USAGE, CREATE ON SCHEMA app TO {role};"

DOCUMENTATION

  8. Update docs/db-tenants.md
     IF file does not exist → create with header.
     Append or update row in Tenant DB Registry table.
     Append or update Tenant Detail section.

  9. Update MANIFEST.md
     Update docs/db-tenants.md last-updated timestamp.

  10. Log to bus
      Write to .crux/bus/postgresql-admin/to-coordinator.jsonl:
      {
        "type": "db-tenant.provisioned",
        "from": "postgresql-admin",
        "tenant": "{tenant-id}",
        "env": "{env}",
        "model": "{schema-per-tenant | database-per-tenant}",
        "object": "{schema or database name}",
        "role": "{role-name}",
        "ts": "{ISO-8601}"
      }

  11. Notify user
      "PostgreSQL provisioned for tenant {tenant-id} ({env}).
       {Schema | Database}: {name}
       Role: {role-name}
       {Read-only role: {ro-role} | —}
       Entry added to docs/db-tenants.md"
```

---

## RECONCILE Mode

Triggered when object exists and user confirms reconcile.

```
Reconcile does NOT:
  - Drop or recreate the schema or database
  - Remove existing tables or data
  - Change the role name

Reconcile DOES:
  - Re-apply GRANT statements (idempotent — use IF NOT EXISTS or GRANT ... ON ALL)
  - Re-apply connection limit on role: ALTER ROLE {role} CONNECTION LIMIT 20
  - Re-apply default privileges
  - Update docs/db-tenants.md entry
  - Log reconcile event to bus

Approval gate for reconcile:
  "I will reconcile {schema | database} {name}:
   - Re-apply GRANT statements
   - Reset connection limit to 20
   - Re-apply default privileges
   No data will be deleted. Proceed? (yes / no)"
```

---

## Error Handling

| Condition | Action |
|---|---|
| Tenant ID format invalid | Stop. Explain rule (underscores only, no hyphens). Ask user to correct. |
| Object already exists (no reconcile) | Ask user: reconcile or abort? |
| psql command fails | Stop. Show error. Do not continue to next step. |
| Role already exists | Skip CREATE ROLE, apply grants to existing role. Notify user. |
| docs/db-tenants.md not writable | Write to workspace/postgresql-admin/output/db-tenants-update.md. Notify user. |
| MEMORY.md missing required fields | Stop. Notify: "Re-run onboarding to configure tenant settings." |
