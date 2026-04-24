---
name: hledger-register-review
description: >
  Reviews detailed hledger register activity for selected accounts, payees,
  tags, or periods. Use when: the user needs transaction detail, account
  movement review, payee analysis, posting inspection, or operational finance
  drill-down from a summary report.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# hledger-register-review

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Provides detailed register and posting review from hledger for specified accounts, payees, or filters.

---

## When to Use Me

- User needs transaction detail behind a report
- Account movement or payee activity should be reviewed
- A summary report needs drill-down

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/chart-of-accounts-guide.md

External requirement:
  hledger MCP configured and reachable

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `query` | user | Yes |
| `period` | user / MEMORY.md | No |
| `limit` | user | No |

---

## Steps

```
1. Resolve query scope and period
2. Query hledger register or print via MCP
3. Group noteworthy movements, payees, or postings
4. Flag duplicates, reversals, or unexpected patterns if visible
5. Write output to docs/finance/YYYY-MM-DD-register-review.md when a saved report is useful
6. Return a concise review
7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-register-review.md` when requested
**Format**: `markdown`

```markdown
# Register Review

## Scope

## Notable Entries
| Date | Description | Account | Amount | Notes |
|---|---|---|---|---|

## Observations
```

---

## Error Handling

| Condition | Action |
|---|---|
| Query too broad | ask user to narrow scope or apply a limit |
| No matching postings | return a no-match summary |
| Unexpected failure | Stop. Write error to bus. Notify user. |
