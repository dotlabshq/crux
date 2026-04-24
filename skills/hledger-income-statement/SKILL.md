---
name: hledger-income-statement
description: >
  Produces an income statement / profit and loss view from hledger and explains
  the main revenue and cost drivers. Use when: the user asks for P&L, period
  performance, expense mix, margin view, or operating result analysis.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# hledger-income-statement

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Builds a period income statement from hledger and highlights revenue, cost, and margin signals.

---

## When to Use Me

- User asks for profit/loss
- Leadership wants period performance
- Expense and income structure should be reviewed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/finance-reporting-rules.md
  .crux/docs/chart-of-accounts-guide.md

External requirement:
  hledger MCP configured and reachable

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `period` | user / MEMORY.md | No |
| `compare-period` | user | No |
| `grouping` | user / MEMORY.md | No |

---

## Steps

```
1. Resolve period and grouping
2. Query hledger income statement via MCP
3. Compare income and expense drivers
4. Flag unusual margin compression or expense concentration where relevant
5. Write output to docs/finance/YYYY-MM-DD-income-statement.md when a saved report is useful
6. Return a concise management summary
7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-income-statement.md` when requested
**Format**: `markdown`

```markdown
# Income Statement

## Scope

## Summary

## Revenue And Cost Breakdown
| Group | Amount | Notes |
|---|---|---|

## Management Observations
```

---

## Error Handling

| Condition | Action |
|---|---|
| Account classification unclear | state grouping assumption explicitly |
| Compare period missing | produce single-period view |
| Unexpected failure | Stop. Write error to bus. Notify user. |
