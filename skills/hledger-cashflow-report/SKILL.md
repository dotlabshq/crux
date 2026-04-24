---
name: hledger-cashflow-report
description: >
  Produces a cash flow view from hledger and explains where cash is coming from
  and where it is going. Use when: the user asks for liquidity movement, cash
  flow for a period, operating cash pressure, or a treasury-style summary.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# hledger-cashflow-report

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Generates a cash flow view from hledger and summarizes the major inflows, outflows, and liquidity signals.

---

## When to Use Me

- User asks for cash flow
- Leadership wants liquidity movement by period
- Cash pressure or funding need should be evaluated

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/finance-reporting-rules.md

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

---

## Steps

```
1. Resolve period
2. Query hledger cash flow via MCP
3. Identify main inflows and outflows
4. Flag liquidity pressure, cash concentration, or unusual movement where relevant
5. Write output to docs/finance/YYYY-MM-DD-cashflow-report.md when a saved report is useful
6. Return a concise management summary
7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-cashflow-report.md` when requested
**Format**: `markdown`

```markdown
# Cash Flow Report

## Scope

## Main Inflows

## Main Outflows

## Key Liquidity Signals
```

---

## Error Handling

| Condition | Action |
|---|---|
| Period missing | use default reporting period |
| Cash accounts unclear | state account-scope assumption explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
