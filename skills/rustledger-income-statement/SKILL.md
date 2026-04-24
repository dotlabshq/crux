---
name: rustledger-income-statement
description: >
  Produces an income statement / profit and loss view from a rustledger-backed
  Beancount ledger. Use when: the user asks for P&L, period performance,
  expense mix, margin trends, or revenue/cost drivers from a Beancount-style
  ledger.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# rustledger-income-statement

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Builds an income statement from rustledger output and explains the main revenue and expense drivers.

---

## When to Use Me

- User asks for P&L from a Beancount ledger
- Leadership wants expense and income structure
- Period performance should be reviewed in a rustledger environment

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/finance-reporting-rules.md
  .crux/docs/rustledger-operating-playbook.md
  .crux/docs/chart-of-accounts-guide.md

External requirement:
  rustledger CLI installed and reachable

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `ledger-file` | user / MEMORY.md | Yes |
| `period` | user / MEMORY.md | No |
| `compare-period` | user | No |

---

## Steps

```
1. Validate ledger file with rustledger check
2. Produce P&L query/report for the requested period
3. Highlight major revenue and cost drivers
4. Write output to docs/finance/YYYY-MM-DD-rustledger-income-statement.md when a saved report is useful
5. Return a concise management summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-rustledger-income-statement.md` when requested
**Format**: `markdown`

```markdown
# Rustledger Income Statement

## Scope

## Revenue And Cost Breakdown
| Group | Amount | Notes |
|---|---|---|

## Management Observations
```

---

## Error Handling

| Condition | Action |
|---|---|
| rustledger validation fails | stop and report ledger errors |
| Compare period missing | produce single-period view |
| Unexpected failure | Stop. Write error to bus. Notify user. |
