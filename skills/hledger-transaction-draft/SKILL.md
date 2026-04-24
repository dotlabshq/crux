---
name: hledger-transaction-draft
description: >
  Converts a business event into one or more candidate hledger journal entries
  without applying them. Use when: the user has an invoice, payment, expense,
  adjustment, reimbursement, accrual, or correction that should become a draft
  journal entry before writeback.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-write
  approval: No
---

# hledger-transaction-draft

**Owner**: `ledger-finance-manager`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns a business event into a candidate hledger entry and explains the accounting logic and uncertainties.

---

## When to Use Me

- User wants to record an invoice, payment, refund, payroll-related item, or adjustment
- A ledger write should start with a reviewable draft
- Accounting intent needs structured alternatives before mutation

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/chart-of-accounts-guide.md
  .crux/docs/hledger-operating-playbook.md

Estimated token cost: ~650 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `event-description` | user | Yes |
| `amount` | user | Yes |
| `date` | user | No |
| `counterparty` | user | No |
| `supporting-context` | user | No |

---

## Steps

```
1. Read the business event and supporting context
2. Determine likely debit/credit structure
3. If accounting intent is ambiguous:
   produce 2-3 candidate entries instead of guessing
4. Validate journal syntax format locally in draft form
5. Write output to docs/finance/YYYY-MM-DD-transaction-draft.md
6. Return draft entry plus rationale and open questions
7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-transaction-draft.md`
**Format**: `markdown`

```markdown
# Transaction Draft

## Source Event

## Draft Entry
```journal
YYYY-MM-DD Description
    assets:...
    expenses:...
```

## Rationale

## Open Questions
```

---

## Error Handling

| Condition | Action |
|---|---|
| Accounting intent unclear | provide alternatives, do not force one draft |
| Account mapping missing | state proposed account assumption explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
