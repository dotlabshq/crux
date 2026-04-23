---
name: postgresql-table-audit
description: >
  Audits table naming conventions and structural standards within tenant schemas.
  Checks snake_case compliance, required audit columns (created_at, updated_at),
  missing primary keys, and RLS policy coverage. Reads naming conventions from
  decisions/tenant-naming-conventions.md as the normative source.
  Use when: tenant schema compliance check, pre-release audit, SOC Type 2
  review preparation, onboarding a new tenant with existing tables,
  or investigating naming drift across schemas.
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-only
  approval: "No"
---

# postgresql-table-audit

**Owner**: `postgresql-admin`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Connects to a live PostgreSQL cluster, inspects tenant schemas,
and produces a structured audit report as `docs/db-table-audit.md`.

Checks per schema:
- Table naming: snake_case, no reserved words, length limit
- Required audit columns: `id`, `created_at`, `updated_at` on entity tables
- Primary key presence on all tables
- RLS policy coverage (if RLS is expected by the platform)
- Foreign key naming: `fk_{table}_{referenced_table}`
- Index naming: `idx_{table}_{column(s)}`
- Sequence naming: `seq_{table}_{column}`
- Schema comment presence (tenant identity embedded)

---

## When to Use Me

- `docs/db-table-audit.md` is missing and postgresql-admin is onboarded
- User requests: "audit tables", "check naming", "SOC2 table review"
- Before a new tenant goes to production
- Periodically to detect naming drift

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/postgresql-admin/MEMORY.md
    Fields needed:
      primary-host
      postgresql-version
      tenant-isolation-model     (schema-per-tenant | database-per-tenant)
      tenant-naming-pattern      (to identify tenant schemas)
      multi-tenant               (true | false)

  .crux/decisions/tenant-naming-conventions.md
    Load-when: this skill runs — normative source for all naming rules

Does not load docs/ — all data comes from live database.

Estimated token cost: ~500 tokens (skill) + ~600 tokens (decision doc)
Unloaded after: docs/db-table-audit.md written
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| target-schemas | user or auto-detect | No — audits all tenant schemas if omitted |
| target-tenant | user | No — filters to one tenant if provided |
| strict-rls | user | No — flag to enforce RLS check (default: warn only) |

---

## Steps

```
1. Load naming rules
   Read: .crux/decisions/tenant-naming-conventions.md
   Extract:
     - tenant-id format rule
     - environment names
     - schema naming pattern
     - table naming rules
     - required columns list
   IF file missing → stop: "decisions/tenant-naming-conventions.md not found.
                            Run coordinator to initialise naming standards."

2. Identify tenant schemas
   IF target-schemas provided → use those
   IF target-tenant provided  → derive schema names from pattern + all envs
   ELSE:
     psql ... -c "
       SELECT schema_name
       FROM information_schema.schemata
       WHERE schema_name NOT IN
         ('pg_catalog','information_schema','public','pg_toast')
       ORDER BY schema_name;"
     Filter: schemas that match tenant-naming-pattern
     IF no tenant schemas found → notify: "No tenant schemas detected.
       Expected pattern: {pattern}. Found: {list}. Check MEMORY.md settings."

3. For each tenant schema — run checks

   3a. Schema identity check
       psql ... -c "SELECT obj_description(oid,'pg_namespace')
                    FROM pg_namespace WHERE nspname = '{schema}';"
       PASS: comment contains 'tenant:', 'env:', 'owner:'
       FAIL: comment missing or incomplete

   3b. List all tables, views, sequences in schema
       psql ... -c "
         SELECT table_name, table_type
         FROM information_schema.tables
         WHERE table_schema = '{schema}'
         ORDER BY table_type, table_name;"

   3c. Table naming check (for each TABLE, not VIEW)
       Rules from decisions/tenant-naming-conventions.md:
         snake_case:   name matches ^[a-z][a-z0-9_]*$
         plural:       name ends with s (entity tables) — WARN only, not FAIL
         no prefix:    name does not start with schema name (redundant scoping)
         length:       name <= 63 chars (PostgreSQL identifier limit)
         no reserved:  not in PostgreSQL reserved word list

   3d. Required column check (entity tables — skip views, lookup tables)
       psql ... -c "
         SELECT column_name, data_type, is_nullable, column_default
         FROM information_schema.columns
         WHERE table_schema = '{schema}' AND table_name = '{table}'
           AND column_name IN ('id','created_at','updated_at')
         ORDER BY column_name;"
       PASS: all three present, created_at/updated_at are timestamptz NOT NULL
       WARN: updated_at present but no DEFAULT or trigger to auto-update
       FAIL: created_at or updated_at missing entirely
       FAIL: id column missing

   3e. Primary key check
       psql ... -c "
         SELECT tc.table_name
         FROM information_schema.table_constraints tc
         WHERE tc.constraint_type = 'PRIMARY KEY'
           AND tc.table_schema = '{schema}'
           AND tc.table_name = '{table}';"
       FAIL: no primary key defined

   3f. Foreign key naming check
       psql ... -c "
         SELECT constraint_name
         FROM information_schema.table_constraints
         WHERE constraint_type = 'FOREIGN KEY'
           AND table_schema = '{schema}'
           AND table_name = '{table}';"
       Expected pattern: fk_{table}_{referenced_table}
       WARN: constraint name does not match pattern

   3g. Index naming check
       psql ... -c "
         SELECT indexname FROM pg_indexes
         WHERE schemaname = '{schema}' AND tablename = '{table}'
           AND indexname NOT LIKE '%_pkey';"
       Expected pattern: idx_{table}_{column(s)}
       WARN: index name does not match pattern

   3h. RLS check (if strict-rls flag set, or if any table has RLS enabled)
       psql ... -c "
         SELECT relname, relrowsecurity, relforcerowsecurity
         FROM pg_class c
         JOIN pg_namespace n ON n.oid = c.relnamespace
         WHERE n.nspname = '{schema}' AND c.relkind = 'r';"
       IF strict-rls:
         FAIL: relrowsecurity = false on any table
       ELSE:
         WARN: relrowsecurity = false (note only)

4. Compile results
   For each schema: count PASS, WARN, FAIL per check category
   Overall schema status:
     CLEAN   — 0 failures, 0 warnings
     WARNING — 0 failures, ≥1 warnings
     FAILING — ≥1 failures

5. Write docs/db-table-audit.md (see Output section)

6. Update MANIFEST.md docs entry:
     last-updated: {DATE}
     tokens: {estimated}

7. Skill complete — notify:
   "Table audit complete. {n} schemas checked.
    Clean: {n} · Warnings: {n} · Failing: {n}
    Full report: .crux/docs/db-table-audit.md"
```

---

## Output

**Writes to**: `.crux/docs/db-table-audit.md`

```markdown
# Database Table Audit

> Generated by postgresql-table-audit on {DATE}.
> Naming standard: .crux/decisions/tenant-naming-conventions.md
> Cluster: {host}:{port}
> Schemas audited: {n}
> Update: @postgresql-admin audit tables

## Summary

| Schema | Tables | Clean | Warnings | Failures | Status |
|---|---|---|---|---|---|
| {schema} | {n} | {n} | {n} | {n} | ✓ CLEAN / ⚠ WARNING / ✗ FAILING |

## Schema: {schema}

**Tenant**: {tenant-id} · **Env**: {env} · **Owner**: {email | missing}
**Schema comment**: {present | MISSING}

### Tables

| Table | Naming | id | created_at | updated_at | PK | Issues |
|---|---|---|---|---|---|---|
| {table} | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| {table} | ✓ | ✓ | ✗ MISSING | ✗ MISSING | ✓ | created_at, updated_at missing |

### Naming Violations

| Object | Type | Name | Issue |
|---|---|---|---|
| {table} | TABLE | {name} | Not snake_case |
| {index} | INDEX | {name} | Expected idx_{table}_{col} |

### RLS Coverage

| Table | RLS Enabled | Force RLS |
|---|---|---|
| {table} | {yes | no} | {yes | no} |

---

## Failures Requiring Action

{List of FAIL items across all schemas, sorted by schema}

## Warnings

{List of WARN items — lower priority, address before production}

---
*Last updated: {DATE} — source: live-analysis*
*Naming standard version: decisions/tenant-naming-conventions.md ({date of decision})*
```

---

## Error Handling

| Condition | Action |
|---|---|
| decisions/tenant-naming-conventions.md missing | Stop. Notify: file required as normative source. |
| No tenant schemas detected | Notify with detected schemas and expected pattern. Do not fail silently. |
| psql command fails for a schema | Mark schema as `(error — {reason})` in output, continue with others. |
| docs/ not writable | Write to workspace/postgresql-admin/output/db-table-audit.md. Notify user. |
| More than 50 schemas | Audit first 50 by tenant-id alphabetical order. Note truncation in report. |
```
