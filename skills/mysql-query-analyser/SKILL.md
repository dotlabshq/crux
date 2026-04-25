---
name: mysql-query-analyser
description: >
  Reviews MySQL or MariaDB query behaviour using available explain plans,
  slow-query context, and schema awareness. Use when: the user reports slow
  queries, asks for index/performance review, or wants a practical MySQL query
  tuning direction without premature over-optimization.
license: MIT
compatibility: opencode
metadata:
  owner: mysql-admin
  type: read-write
  approval: No
---

# mysql-query-analyser

**Owner**: `mysql-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces a practical MySQL query analysis focused on likely bottlenecks, access patterns, and next-tuning steps.

---

## When to Use Me

- Slow query investigation
- Index review request
- Performance tuning direction needed

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/mysql-admin/AGENT.md
  .crux/workspace/mysql-admin/MEMORY.md

Estimated token cost: ~650 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `query` | user | Yes |
| `target-database` | user | No |
| `performance-context` | user | No |

---

## Steps

```
1. Confirm query and performance context
2. Review available explain, schema, and index evidence
3. Identify likely bottleneck class
4. Recommend the next tuning move in plain language
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Query context too thin | ask for query, table, and timing evidence |
| Tuning requires app-level change | escalate to backend-developer |
| Unexpected failure | Stop. Write error to bus. Notify user. |
