# Onboarding: MySQL Admin

> This file defines the onboarding sequence for the `mysql-admin` agent.
> Onboarding runs automatically when the agent starts and MANIFEST.md shows `status: pending-onboard`.
> On completion, status is updated to `onboarded`.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/mysql-admin/AGENT.md` exists

If any are missing, stop and notify the user.

---

## Step 1 — Introduce

```
You are setting up the MySQL Admin agent.

This agent manages your MySQL or MariaDB databases — schemas, users,
privileges, replication, backups, query performance, and database-level
tenant provisioning.

I will ask a few questions to configure it correctly.
Type "skip" at any point to defer — I will note it as pending.
```

---

## Step 2 — Environment Discovery

Run the following checks silently. Record results in
`.crux/workspace/mysql-admin/sessions/{id}/scratch.md`.

```
CONNECTION
  mysqladmin --host={host} --port={port} ping
    OK  → record host, port, reachable: true
    ERR → mark db-unreachable, surface in Step 3

  mysql --host={host} --port={port} -e "SELECT VERSION();"
    OK  → record mysql-version
    ERR → mark connect-failed

TOPOLOGY
  mysql ... -e "SHOW DATABASES;"
    OK  → record database list
    ERR → mark databases-unknown

  mysql ... -e "SELECT User, Host FROM mysql.user;"
    OK  → record user list (names only)
    ERR → mark users-unknown

  mysql ... -e "SHOW REPLICA STATUS\\G"  OR "SHOW SLAVE STATUS\\G"
    OK  → record replication role and lag signals
    ERR → mark replication-unknown

BACKUP AND MONITORING
  Check whether dump or backup tooling is present/configured
  Check whether slow_query_log and long_query_time are visible
  Record what can be discovered; mark unknown where needed

MULTI-TENANCY INDICATORS
  Review database naming patterns and non-system schemas
  Record whether tenant-style naming appears to exist
```

---

## Step 3 — User Questions

Ask one at a time. Show discovered value as default where applicable.

```
Question 1 — Connection details
  IF db-unreachable OR connect-failed:
    "I could not connect to MySQL. Please provide:
     - Host and port
     - Username with read access
     - Password or connection method"
  ELSE:
    "I found MySQL/MariaDB {version} at {host}:{port}. Is this correct?"
  stores-to: workspace/mysql-admin/MEMORY.md → primary-host, mysql-version

Question 2 — Production databases
  "Which databases should I treat as production?
   These require your manual approval before any schema or privilege changes."
  default: none
  stores-to: workspace/mysql-admin/MEMORY.md → production-databases

Question 3 — Replication lag threshold
  "What replication lag should trigger an alert?"
  default: 60s
  stores-to: workspace/mysql-admin/MEMORY.md → replication-lag-threshold

Question 4 — Multi-tenancy
  "Is this MySQL estate shared across multiple tenants?"
  default: yes
  stores-to: workspace/mysql-admin/MEMORY.md → multi-tenant

Question 5 — Tenant naming convention
  "What naming convention should I enforce for tenant databases or table prefixes?"
  default: {tenant-id}_{env}
  stores-to: workspace/mysql-admin/MEMORY.md → tenant-naming-pattern

Question 6 — Access method
  "How do you usually reach MySQL/MariaDB?
   Examples:
     direct host:port
     bastion/jump host
     kubectl exec into a MySQL pod
     kubectl port-forward to a service or pod
   If a working method exists, I will store and reuse it."
  stores-to: workspace/mysql-admin/MEMORY.md → access-method-default
```

---

## Step 4 — Generate Docs

```
Run sequentially:

  1. mysql-schema-analyser     → docs/mysql.md
     Trigger: always during onboarding
     Condition: skip if db-unreachable (noted in NOTES.md as pending)

  2. Generate docs/mysql-tenants.md
     Trigger: if multi-tenant: true
     Source: discovery + question answers

  3. doc-summariser            → summaries/mysql.md
     Trigger: after docs/mysql.md is written
```

If MySQL/MariaDB is discovered inside Kubernetes, ask `kubernetes-admin` for the working namespace/pod/service access path, then store the verified method in `MEMORY.md` so future runs reuse it instead of rediscovering access.

---

## Step 5 — Review & Confirm

Summarise:
- MySQL/MariaDB version and host
- detected databases
- replication posture
- production database list
- tenant naming convention

---

## Step 6 — Finalise

1. Write all collected facts to `.crux/workspace/mysql-admin/MEMORY.md`
2. Update agent status to `onboarded`
3. Broadcast `agent.onboarded`
4. Notify user that `@mysql-admin` is ready
