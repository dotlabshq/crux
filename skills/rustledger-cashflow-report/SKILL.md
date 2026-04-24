---
name: rustledger-cashflow-report
description: >
  Produces a cash flow style view from a rustledger-compatible Beancount
  ledger. Use when: the user asks for liquidity movement, cash source and use,
  operating cash pressure, or treasury-style cash analysis from a Beancount
  ledger.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# rustledger-cashflow-report

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Builds a cash movement view from a rustledger-backed ledger and explains the main inflows and outflows.

---

## When to Use Me

- User asks for cash flow from a Beancount ledger
- Liquidity movement needs review
- Finance wants treasury-style movement visibility

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

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `ledger-file` | user / MEMORY.md | Yes |
| `period` | user / MEMORY.md | No |

---

## Steps

```
1. Validate ledger file with rustledger check
2. Query or report cash-related movement for the selected period
3. Group major inflows and outflows
4. Write output to docs/finance/YYYY-MM-DD-rustledger-cashflow-report.md when a saved report is useful
5. Return a concise management summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-rustledger-cashflow-report.md` when requested
**Format**: `markdown`

```markdown
# Rustledger Cash Flow Report

## Scope

## Main Inflows

## Main Outflows

## Key Liquidity Signals
```

---

## Error Handling

| Condition | Action |
|---|---|
| rustledger validation fails | stop and report ledger errors |
| Cash account scope ambiguous | state account-scope assumption |
| Unexpected failure | Stop. Write error to bus. Notify user. |
