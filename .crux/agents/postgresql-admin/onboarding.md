# Onboarding: PostgreSQL Admin

> This file defines the onboarding sequence for the `postgresql-admin` agent.
> Onboarding runs automatically when the agent starts and
> MANIFEST.md shows `status: pending-onboard`.
> On completion, status is updated to `onboarded`.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/postgresql-admin/AGENT.md` exists

If any are missing, stop and notify the user.

---

## Step 1 — Introduce

```
You are setting up the PostgreSQL Admin agent.

This agent manages your PostgreSQL databases — schemas, roles, replication,
connection pooling, backups, query performance, and database-level tenant provisioning.
It enforces role boundaries, tracks backup posture, and maintains SOC Type 2
compliance for the database layer.

I will ask a few questions to configure it correctly.
Type "skip" at any point to defer — I will note it as pending.
```

---

## Step 2 — Environment Discovery

Run the following checks silently. Record results in
`.crux/workspace/postgresql-admin/sessions/{id}/scratch.md`.

```
CONNECTION
  pg_isready -h {host} -p {port}
    OK  → record host, port, reachable: true
    ERR → mark db-unreachable, surface in Step 3

  psql -h {host} -p {port} -U {user} -c "SELECT version();"
    OK  → record postgresql-version
    ERR → mark connect-failed (credentials or auth issue)

TOPOLOGY
  psql ... -c "SELECT pg_is_in_recovery();"
    false → this is primary
    true  → this is a replica — note, continue

  psql ... -c "SELECT * FROM pg_stat_replication;"
    OK rows  → record replica-count, replication-type: streaming
    No rows  → check for patroni or pgpool via process list or pg_extension
    ERR      → mark replication-unknown

  psql ... -c "\l+"
    OK  → record database list, sizes
    ERR → mark databases-unknown

  psql ... -c "\du"
    OK  → record role list (names only, not passwords)
    ERR → mark roles-unknown

CONNECTION POOLING
  pg_isready -h {host} -p 6432  (pgBouncer default port)
    OK  → mark pgbouncer-detected, record port
    ERR → try port 5433 for pgPool
          ERR → mark pooler-missing

  IF pgbouncer detected:
    psql -h {host} -p 6432 pgbouncer -c "SHOW VERSION;"
    psql -h {host} -p 6432 pgbouncer -c "SHOW POOLS;"
      OK → record pooler: pgbouncer, mode (transaction/session), pool-size

SOC TYPE 2 — AUDIT LOGGING
  psql ... -c "SELECT * FROM pg_extension WHERE extname = 'pgaudit';"
    OK  → record pgaudit: enabled
    ERR → mark pgaudit-missing

  psql ... -c "SHOW log_connections; SHOW log_disconnections; SHOW log_duration;"
    Record values — note if all are off

SOC TYPE 2 — ENCRYPTION
  psql ... -c "SHOW ssl;"
    on  → record ssl: enabled
    off → mark ssl-disabled

  psql ... -c "SELECT datname, pg_encoding_to_char(encoding) FROM pg_database;"
    Record encoding per database (expect UTF8)

SOC TYPE 2 — BACKUP
  Check for pgBackRest config: ls /etc/pgbackrest/ 2>/dev/null
    OK  → mark backup-tool: pgbackrest
  Check for pg_basebackup schedule: check cron or systemd units
    OK  → record backup-schedule
  ELSE → mark backup-unknown

SOC TYPE 2 — MONITORING
  psql ... -c "SELECT * FROM pg_extension WHERE extname = 'pg_stat_statements';"
    OK  → mark pg-stat-statements: enabled
    ERR → mark pg-stat-statements-missing

  Check for postgres_exporter process:
    psql ... -c "SELECT COUNT(*) FROM pg_stat_activity WHERE application_name LIKE '%exporter%';"
    OR: pg_isready on common exporter ports (9187)
      OK  → mark postgres-exporter: detected
      ERR → mark postgres-exporter-missing

MULTI-TENANCY INDICATORS
  psql ... -c "SELECT schema_name FROM information_schema.schemata
               WHERE schema_name NOT IN ('pg_catalog','information_schema','public')
               ORDER BY schema_name;"
    Record: non-system schema list
    Check: do schemas follow a pattern (tenant_id prefix, etc.)?
    Record: tenant-schema-pattern (detected | unknown)

  psql ... -c "\du" (check for per-tenant roles)
    Check: do roles follow a pattern matching schema names?
    Record: tenant-role-pattern (detected | unknown)
```

---

## Step 3 — User Questions

Ask one at a time. Show discovered value as default where applicable.

```
Question 1 — Connection details
  IF db-unreachable OR connect-failed:
    "I could not connect to PostgreSQL. Please provide:
     - Host and port (e.g. postgres.internal:5432)
     - Username with read access
     - Password or connection method (env var, .pgpass, PGPASSFILE)"
  ELSE:
    "I found PostgreSQL {version} at {host}:{port}. Is this correct?"
  stores-to: workspace/postgresql-admin/MEMORY.md → primary-host, postgresql-version

Question 2 — Production databases
  "Which databases should I treat as production?
   These require your manual approval before any schema or privilege changes.
   (Discovered: {list})"
  default: none
  stores-to: workspace/postgresql-admin/MEMORY.md → production-databases

Question 3 — Replication lag threshold
  "What replication lag should trigger an alert?
   (I will surface a warning at session start if lag exceeds this.)"
  default: 60s
  stores-to: workspace/postgresql-admin/MEMORY.md → replication-lag-threshold

Question 4 — Multi-tenancy
  "Is this database shared across multiple tenants (separate schemas or databases
   per customer, team, or environment)?"
  default: yes
  IF yes → continue to Question 5
  IF no  → set multi-tenant: false in MEMORY.md

Question 5 — Tenant isolation model
  "How are tenants isolated in the database?
     schema-per-tenant   — each tenant has its own schema in a shared database
                           e.g. acme_prod, acme_staging inside app_db
     database-per-tenant — each tenant has its own database
                           e.g. app_acme_prod, app_acme_staging
     hybrid              — describe your model"
  default: schema-per-tenant
  stores-to:
    workspace/postgresql-admin/MEMORY.md → tenant-isolation-model
    docs/postgresql.md → Tenancy section

Question 6 — Tenant naming convention
  "What naming convention should I enforce for tenant schemas or databases?
   Common patterns:
     {tenant-id}_{env}         e.g. acme_prod, acme_staging
     {env}_{tenant-id}         e.g. prod_acme, staging_acme
   Or describe your own."
  default: {tenant-id}_{env}
  stores-to:
    workspace/postgresql-admin/MEMORY.md → tenant-naming-pattern
    docs/db-tenants.md → Naming Convention section

Question 7 — Backup posture
  IF backup-unknown:
    "I could not detect a backup tool. Do you have a backup strategy configured?
     (e.g. pgBackRest, pg_basebackup, cloud snapshots)
     Describe it or type 'skip' to address later."
  ELSE:
    "I detected {backup-tool}. Is the backup schedule documented somewhere I should know?"
  stores-to: workspace/postgresql-admin/MEMORY.md → backup-tool, backup-schedule
```

---

## Step 4 — Generate Docs

```
Run sequentially:

  1. postgresql-schema-analyser  →  docs/postgresql.md
     Trigger: always during onboarding
     Condition: skip if db-unreachable (noted in NOTES.md as pending)

  2. Generate docs/db-tenants.md
     Trigger: if multi-tenant: true
     Source: discovery + Question 5, 6 answers
     Write initial tenant registry with discovered schemas or databases.

  3. doc-summariser              →  summaries/postgresql.md
     Trigger: after docs/postgresql.md is written
```

---

## Step 5 — SOC Type 2 Gap Report

```
IF any of the following were marked during Step 2:
  pgaudit-missing
  ssl-disabled
  backup-unknown
  pg-stat-statements-missing
  postgres-exporter-missing
  pooler-missing

Present to user:

  "SOC Type 2 compliance gaps detected for the database layer:

   ✗ Audit logging (pgaudit)         — extension not detected
   ✗ SSL enforcement                 — ssl = off on server
   ✗ Backup strategy                 — no backup tool detected
   ✗ Query monitoring (pg_stat_statements) — extension not enabled
   ✗ Metrics exporter                — postgres_exporter not detected
   ✗ Connection pooler               — pgBouncer/pgPool not detected

   I have added these as pending tasks in your NOTES.md.
   Address them before your next SOC Type 2 review.
   Type 'skip' to defer, or 'prioritise {item}' to address one now."

Write each gap to .crux/workspace/postgresql-admin/NOTES.md
under: ## Pending Tasks — SOC Type 2 Gaps
with: status: open, discovered: {DATE}
```

---

## Step 6 — Review & Confirm

```
"Onboarding summary for PostgreSQL Admin:

  Primary host:       {host}:{port}
  Version:            {version}
  Replication:        {type | none detected}
  Replica count:      {n}
  Connection pooler:  {pgbouncer version + mode | none}
  Production DBs:     {list | none}
  Multi-tenant:       {yes | no}
  Isolation model:    {schema-per-tenant | database-per-tenant | hybrid | —}
  Naming pattern:     {pattern | —}
  Backup:             {tool + schedule | unknown}
  Lag threshold:      {value}

  Docs generated:
    {✓ | ✗} docs/postgresql.md
    {✓ | ✗} docs/db-tenants.md
    {✓ | ✗} summaries/postgresql.md

  SOC Type 2 gaps: {n gaps | none detected}

Does this look correct?
  → yes: finalise
  → no: tell me what to fix"
```

---

## Step 7 — Finalise

```
1. Write all collected facts to .crux/workspace/postgresql-admin/MEMORY.md
   using minimum metadata format (key, value, source, verified_at, verified_by, status, scope):
     primary-host
     postgresql-version
     replication-type
     replica-count
     connection-pooler
     production-databases
     multi-tenant
     tenant-isolation-model
     tenant-naming-pattern
     backup-tool
     backup-schedule
     pgaudit
     ssl
     pg-stat-statements
     postgres-exporter
     replication-lag-threshold
     onboarded-date

2. Update .crux/workspace/MANIFEST.md:
     agents.postgresql-admin.status       → onboarded
     agents.postgresql-admin.docs         → ✓
     agents.postgresql-admin.last-session → {DATE}
   Add doc rows: postgresql.md, db-tenants.md

3. Write event to .crux/bus/broadcast.jsonl:
   { "type": "agent.onboarded", "from": "postgresql-admin", "ts": "..." }

4. Notify user:
   "PostgreSQL Admin is ready.
    Type @postgresql-admin to assign tasks."
```

---

## Re-Onboarding

Onboarding can be re-run at any time:
- User requests it explicitly
- A required docs/ file is deleted
- MANIFEST.md status is manually reset to `pending-onboard`

Re-onboarding does not overwrite existing MEMORY.md entries —
it appends or updates only the fields it collects.
