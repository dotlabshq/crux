---
name: hledger-balance-report
description: >
  Produces balance views from hledger by account, account group, or selected
  period. Use when: the user wants current balances, account totals, balance by
  category, or a management view of ledger positions for a chosen scope.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# hledger-balance-report

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Generates balance reports from hledger for the requested period and scope, then explains the main positions in plain language.

---

## When to Use Me

- User asks for current balances
- Leadership wants account totals or grouped balances
- A quick ledger position view is needed for a period

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/finance-reporting-rules.md

External requirement:
  hledger MCP configured and reachable
  Expected tool namespace: mcp__hledger__*

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `period` | user / MEMORY.md | No — default from MEMORY.md |
| `account-filter` | user | No |
| `depth` | user | No |

---

## Steps

```
1. Resolve reporting period and scope
2. Query hledger balance via MCP
3. Group by requested account depth or family
4. Highlight unusual concentrations or negative balances if relevant
5. Write output to docs/finance/YYYY-MM-DD-balance-report.md when a saved report is useful
6. Return a concise management summary
7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-balance-report.md` when requested
**Format**: `markdown`

```markdown
# Balance Report

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
| Period missing | use MEMORY.md default and state assumption |
| MCP unavailable | stop and report configuration blocker |
| No matching accounts | return no-match summary with applied filters |
| Unexpected failure | Stop. Write error to bus. Notify user. |
