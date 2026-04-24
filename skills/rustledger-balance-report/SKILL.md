---
name: rustledger-balance-report
description: >
  Produces balance views from a rustledger-compatible Beancount ledger using
  rustledger reporting or query commands. Use when: the user wants current
  balances, account totals, grouped positions, or a management balance view
  from a Beancount-style ledger.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# rustledger-balance-report

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Generates balance views from a rustledger-compatible Beancount ledger and summarizes the main positions.

---

## When to Use Me

- User asks for balances from a Beancount ledger
- Leadership wants grouped balances by account family
- A rustledger-backed reporting view is needed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/finance-reporting-rules.md
  .crux/docs/rustledger-operating-playbook.md

External requirement:
  rustledger CLI installed and reachable
  Expected command family:
    rledger check
    rledger query
    rledger report

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `ledger-file` | user / MEMORY.md | Yes |
| `period` | user / MEMORY.md | No |
| `account-filter` | user | No |

---

## Steps

```
1. Validate ledger file path
2. Run rustledger check on the target file
3. Query or report balances for the requested scope
4. Group results for management readability
5. Write output to docs/finance/YYYY-MM-DD-rustledger-balance-report.md when a saved report is useful
6. Return a concise summary
7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-rustledger-balance-report.md` when requested
**Format**: `markdown`

```markdown
# Rustledger Balance Report

## Scope

## Balances
| Account | Balance | Notes |
|---|---|---|

## Key Observations
```

---

## Error Handling

| Condition | Action |
|---|---|
| Ledger file missing | stop and report path issue |
| rustledger check fails | stop and report validation errors first |
| No matching accounts | return a no-match summary |
| Unexpected failure | Stop. Write error to bus. Notify user. |
