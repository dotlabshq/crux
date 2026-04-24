---
name: rustledger-register-review
description: >
  Reviews detailed transaction and posting activity from a rustledger-backed
  Beancount ledger using queries and report tooling. Use when: the user needs
  transaction detail, payee or account drill-down, BQL-driven inspection, or a
  deeper review behind a summary report.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# rustledger-register-review

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Provides detailed register and posting review from a rustledger-compatible ledger.

---

## When to Use Me

- User needs transaction detail behind a Beancount report
- Payee, account, or posting activity should be inspected
- A rustledger/BQL drill-down is needed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/rustledger-operating-playbook.md
  .crux/docs/chart-of-accounts-guide.md

External requirement:
  rustledger CLI installed and reachable

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `ledger-file` | user / MEMORY.md | Yes |
| `query` | user | Yes |
| `period` | user | No |

---

## Steps

```
1. Validate ledger file with rustledger check
2. Run a narrow query/report for the requested scope
3. Highlight notable entries, payees, tags, or postings
4. Write output to docs/finance/YYYY-MM-DD-rustledger-register-review.md when a saved report is useful
5. Return a concise review
6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-rustledger-register-review.md` when requested
**Format**: `markdown`

```markdown
# Rustledger Register Review

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
| Query too broad | ask user to narrow the scope |
| rustledger validation fails | stop and report ledger errors |
| Unexpected failure | Stop. Write error to bus. Notify user. |
