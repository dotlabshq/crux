---
name: rustledger-transaction-draft
description: >
  Converts a business event into one or more candidate Beancount transactions
  for a rustledger-backed ledger without applying them. Use when: the user has
  an invoice, payment, expense, refund, accrual, or adjustment that should
  become a draft Beancount transaction before writeback.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-write
  approval: No
---

# rustledger-transaction-draft

**Owner**: `ledger-finance-manager`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns a business event into a candidate Beancount transaction and explains the accounting logic and uncertainties.

---

## When to Use Me

- A business event should become a Beancount transaction draft
- A writeback workflow should start with a reviewable draft
- Accounting intent is not yet strong enough for immediate ledger mutation

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/chart-of-accounts-guide.md
  .crux/docs/rustledger-operating-playbook.md

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
2. Determine likely debit/credit postings
3. If intent is ambiguous:
   produce alternatives instead of guessing
4. Write output to docs/finance/YYYY-MM-DD-rustledger-transaction-draft.md
5. Return draft transaction plus rationale and open questions
6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-rustledger-transaction-draft.md`
**Format**: `markdown`

```markdown
# Rustledger Transaction Draft

## Source Event

## Draft Transaction
```beancount
YYYY-MM-DD * "Description"
  Assets:...
  Expenses:...   100 TRY
```

## Rationale

## Open Questions
```

---

## Error Handling

| Condition | Action |
|---|---|
| Account mapping unclear | provide alternatives and assumptions |
| Business event too vague | stop and ask for missing evidence |
| Unexpected failure | Stop. Write error to bus. Notify user. |
