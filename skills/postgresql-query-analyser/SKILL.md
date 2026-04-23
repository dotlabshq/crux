---
name: postgresql-query-analyser
description: >
  Analyses slow and expensive queries using pg_stat_statements. Identifies
  top queries by total time, mean time, and call frequency. Runs EXPLAIN ANALYZE
  on selected queries with user approval. Produces a prioritised list of
  optimisation candidates with index suggestions.
  Use when: performance complaint, slow query report, pre-release perf review,
  or pg_stat_statements review.
license: MIT
compatibility: opencode
metadata:
  owner: postgresql-admin
  type: read-only
  approval: "No — EXPLAIN ANALYZE requires approval"
---

# postgresql-query-analyser

**Owner**: `postgresql-admin`
**Type**: `read-only` (EXPLAIN ANALYZE requires approval)
**Approval**: `No` (approval required only for EXPLAIN ANALYZE step)

---

## What I Do

Connects to a target PostgreSQL database, reads `pg_stat_statements` to surface
the most expensive queries, and produces a ranked optimisation candidate list.
Optionally runs `EXPLAIN (ANALYZE, BUFFERS)` on specific queries after approval.
Read-only — does not modify schemas, indexes, or configuration.

---

## When to Use Me

- User reports: "slow queries", "database performance", "high latency", "CPU spike"
- User requests: "query analysis", "what's the slowest query", "pg_stat_statements"
- Pre-release performance review
- After a new feature deployment that changed query patterns

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/postgresql-admin/MEMORY.md
    Fields needed:
      primary-host
      primary-port
      admin-user
      target-database  (or ask user)

Estimated token cost: ~450 tokens
Unloaded after: analysis delivered
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| target-database | user or MEMORY.md | Yes |
| top-n | user | No — default 10 queries |
| min-calls | user | No — default 5 (filter out rarely-called queries) |
| run-explain | user | No — default false (requires approval if true) |

---

## Steps

```
1. Verify pg_stat_statements is available
   psql -d {db} ... -c "SELECT 1 FROM pg_extension WHERE extname='pg_stat_statements';"
   IF not installed → stop:
     "pg_stat_statements extension is not installed.
      To install: CREATE EXTENSION pg_stat_statements;
      Then add to postgresql.conf: shared_preload_libraries = 'pg_stat_statements'
      and restart PostgreSQL."

2. Check pg_stat_statements reset time
   psql -d {db} ... -c "SELECT stats_reset FROM pg_stat_statements_info;" 2>/dev/null
   Note: if reset was recent (< 1h), data may not be representative

3. Fetch top queries by total time
   psql -d {db} ... -c "
     SELECT
       queryid,
       calls,
       round(total_exec_time::numeric, 2)   AS total_ms,
       round(mean_exec_time::numeric, 2)    AS mean_ms,
       round(stddev_exec_time::numeric, 2)  AS stddev_ms,
       rows,
       round(100.0 * total_exec_time /
         sum(total_exec_time) OVER (), 2)   AS pct_total,
       shared_blks_hit,
       shared_blks_read,
       query
     FROM pg_stat_statements
     WHERE calls >= {min-calls}
       AND query NOT LIKE '%pg_stat_statements%'
     ORDER BY total_exec_time DESC
     LIMIT {top-n};"

4. Fetch top queries by mean time (different sort — may surface occasional slow ones)
   Same query but ORDER BY mean_exec_time DESC LIMIT {top-n / 2}

5. Detect missing index candidates
   For each top query:
     IF shared_blks_read / (shared_blks_hit + shared_blks_read) > 0.3
       → high block read ratio: possible sequential scan, index may help
     IF query contains WHERE clause on non-indexed columns (heuristic from EXPLAIN)
       → flag for EXPLAIN review

6. IF run-explain = true (or user requests explain for specific query)
   REQUIRE APPROVAL:
     "Ready to run EXPLAIN (ANALYZE, BUFFERS) on the following query in database {db}:
      {query text truncated to 500 chars}
      This is read-only but will execute the query against live data.
      Proceed? (yes / no)"
   On yes:
     psql -d {db} ... -c "EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) {query};"
   Parse output:
     - Identify Seq Scans on large tables
     - Identify high-cost nodes
     - Identify nested loop joins on large sets
     - Extract actual vs estimated row counts (bad estimates = stale statistics)
   Suggest: CREATE INDEX, ANALYZE {table}, or query rewrite

7. Compile results
   Rank by: total_ms descending (primary), mean_ms (secondary)
   For each query: rank, stats summary, optimisation opportunity, suggested action

8. Report inline
```

---

## Output

Delivered inline. Format:

```
## Query Analysis — {database} — {DATE}

pg_stat_statements stats since: {stats_reset}
Total queries analysed: {n} (filtered: calls >= {min-calls})

### Top Queries by Total Time

| Rank | Calls | Total ms | Mean ms | % of DB time | Opportunity |
|---|---|---|---|---|---|
| 1 | {n} | {ms} | {ms} | {pct}% | Missing index on users.email |
| 2 | {n} | {ms} | {ms} | {pct}% | Sequential scan — table needs ANALYZE |

### Query #1 — {pct}% of total DB time

```sql
{normalised query text}
```

Stats:
  Calls:         {n}
  Total time:    {ms}ms
  Mean time:     {ms}ms  (stddev: {ms}ms)
  Rows returned: {n} avg
  Cache hit ratio: {pct}%  ← LOW if < 70%

Opportunities:
  - High block read ratio ({pct}%) — possible sequential scan
  - Suggested: CREATE INDEX idx_{table}_{col} ON {table}({col});

### Summary

High priority (> 10% of DB time):  {n} queries
Medium priority (1-10%):           {n} queries
Consider EXPLAIN ANALYZE:          {n} queries flagged

Next step: run with --run-explain to get EXPLAIN ANALYZE on top candidates.
```

---

## Error Handling

| Condition | Action |
|---|---|
| pg_stat_statements not installed | Stop. Provide installation instructions. |
| psql not found | Stop. Notify. |
| Connection refused | Stop. Notify with host:port. |
| stats_reset within last hour | Warn: data may not be representative, note reset time. |
| No queries meet min-calls threshold | Lower threshold to 1, note in output. |
| Query text contains sensitive patterns (password, secret, token) | Redact value in displayed output. |
