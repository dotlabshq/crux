---
name: postgresql-backup-verify
description: >
  Verifies PostgreSQL backup health: checks last successful backup timestamp,
  backup size, WAL archiving status, and retention policy compliance.
  Supports pgBackRest, pg_basebackup, and WAL-G. Reports SOC Type 2 relevant
  findings (backup age, gap detection, restore-readiness).
  Use when: backup status question, SOC Type 2 audit, incident prep,
  or scheduled backup health check.
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-only
  approval: "No"
---

# postgresql-backup-verify

**Owner**: `postgresql-admin`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Detects the active backup solution (pgBackRest, WAL-G, or pg_basebackup),
queries backup history and WAL archiving status, and produces a health
report with SOC Type 2 relevant findings. Read-only — does not trigger
or modify backups.

---

## When to Use Me

- User asks: "backup status", "last backup", "is backup healthy", "SOC2 backup check"
- Scheduled backup health review
- After a cluster incident or failover
- postgresql-admin onboarding SOC Type 2 gap report

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/postgresql-admin/MEMORY.md
    Fields needed:
      primary-host
      primary-port
      admin-user
      backup-tool         (pgbackrest | walg | pg_basebackup | unknown)
      backup-retention-days  (expected retention, e.g. 30)
      wal-archiving       (true | false)

Estimated token cost: ~450 tokens
Unloaded after: report delivered
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| stanza | user or MEMORY.md | No — pgBackRest stanza name (default: main) |
| max-backup-age-hours | user | No — alert threshold (default: 25 for daily backups) |

---

## Steps

```
1. Detect backup tool
   IF MEMORY.md backup-tool known → use it
   ELSE auto-detect:
     command -v pgbackrest 2>/dev/null  → pgbackrest
     command -v wal-g       2>/dev/null  → walg
     command -v pg_basebackup 2>/dev/null → pg_basebackup
   IF none detected → note "no backup tool found in PATH", check WAL archiving only

2. Check WAL archiving status
   psql -h {host} ... -c "
     SELECT archived_count, failed_count, last_archived_wal,
            last_archived_time, last_failed_wal, last_failed_time
     FROM pg_stat_archiver;"
   FLAG: failed_count > 0 → FAIL
   FLAG: last_archived_time > NOW() - INTERVAL '2 hours' → WARN (WAL gap)
   FLAG: last_failed_time > last_archived_time → FAIL (active archiving failure)

3. Check backup history

   IF pgbackrest:
     pgbackrest --stanza={stanza} info --output=json 2>/dev/null
     Parse: last full backup timestamp, backup size, WAL range covered
     pgbackrest --stanza={stanza} check 2>/dev/null

   IF walg:
     wal-g backup-list --detail 2>/dev/null | tail -5
     wal-g wal-verify integrity 2>/dev/null

   IF pg_basebackup or unknown:
     Check pg_stat_archiver (already done in step 2)
     Look for backup logs in common paths:
       /var/log/postgresql/backup*.log
       /var/log/pgbackrest/*.log
     Note: cannot verify backup completeness without a dedicated tool

4. Evaluate backup age
   last_backup_time = most recent successful backup timestamp
   age_hours = (NOW - last_backup_time) in hours
   IF age_hours > max-backup-age-hours (default 25):
     FAIL — last backup is {age_hours}h old, expected < {threshold}h
   ELSE:
     OK — last backup {age_hours}h ago

5. Check retention compliance
   IF backup-retention-days set in MEMORY.md:
     Count backups available going back {retention-days} days
     IF gap found → WARN — retention policy may not be met

6. Check restore readiness (pgBackRest only)
   pgbackrest --stanza={stanza} check
   PASS: check exits 0
   FAIL: check exits non-zero — note output

7. Compile results
   Status:
     HEALTHY  — backup recent, WAL archiving OK, no failures
     WARNING  — backup within threshold but warnings present
     CRITICAL — backup age exceeded, or active archiving failure

8. Report inline
   Summary + SOC Type 2 relevant findings
```

---

## Output

Delivered inline. Format:

```
## Backup Health — {DATE}

Backup tool:      {pgbackrest | walg | pg_basebackup | none detected}
WAL archiving:    {OK — last {time} | WARN — gap {duration} | FAIL — {reason}}

### Last Backup
  Time:     {ISO8601}
  Age:      {n}h {n}m  ← FAIL if > threshold
  Size:     {size}
  WAL from: {start-lsn} to {end-lsn}
  Status:   {OK | FAIL — {reason}}

### Retention ({n} days expected)
  Backups available: {n}
  Oldest backup:     {date}
  Coverage gap:      {none | {date range}}  ← WARN if gap

### WAL Archiving
  Archived:    {count} WAL files
  Failed:      {count}  ← FAIL if > 0
  Last success: {timestamp}
  Last failure: {timestamp | none}

### SOC Type 2 Summary
  ✓ / ✗  Backup frequency: daily within 25h window
  ✓ / ✗  Retention: {n} days covered
  ✓ / ✗  WAL archiving: no active failures
  ✓ / ✗  Restore check: passed (pgBackRest) | not verified

### Issues
{list of FAIL and WARN items with remediation hints}
```

---

## Error Handling

| Condition | Action |
|---|---|
| psql not found | Stop. Notify. |
| Connection refused | Stop. Notify with host:port. |
| pgbackrest / wal-g not in PATH | Note tool absent, fall back to WAL archiver stats only. |
| pgbackrest info returns no stanza | List available stanzas. Ask user to specify. |
| pg_stat_archiver shows no activity | WARN — WAL archiving may be disabled. Check postgresql.conf archive_mode. |
| last_failed_time NULL | Normal — no failures ever recorded. |
