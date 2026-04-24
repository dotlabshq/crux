# Onboarding: Ledger Finance Manager

> This file defines the onboarding sequence for the `ledger-finance-manager` agent.
> Onboarding configures hledger-backed reporting defaults and safe journal operation rules.

---

## Prerequisites

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/ledger-finance-manager/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Explain that this agent:
- reads finance data through hledger MCP
- produces balances, P&L, cash flow, and register views
- drafts and can apply journal mutations
- does not replace a licensed accountant or statutory filing process

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Check whether hledger MCP is configured and reachable
  2. Check whether the primary journal path is known
  3. Check whether read-only mode is enabled
  4. Check whether backup skip is enabled
  5. Check whether .crux/docs/finance-reporting-rules.md exists
  6. Check whether .crux/docs/hledger-operating-playbook.md exists
  7. Check whether .crux/docs/chart-of-accounts-guide.md exists
```

Record missing items in scratch notes.

---

## Step 3 — User Questions

Ask one question at a time:

1. "What should be the default reporting period?
    Examples: current-month / last-30-days / current-quarter"
   default: current-month
   stores-to: MEMORY.md → default-report-period

2. "Which currency should management summaries prioritize?"
   default: journal default currency
   stores-to: MEMORY.md → reporting-currency

3. "Should journal write operations default to draft-first or direct writeback after validation?"
   default: draft-first
   stores-to: MEMORY.md → journal-write-mode

4. "Should leadership summaries focus on detailed accounts or grouped account families by default?"
   default: grouped account families
   stores-to: MEMORY.md → default-report-granularity

---

## Step 4 — Generate Docs

If missing, generate:
- `.crux/docs/finance-reporting-rules.md`
- `.crux/docs/hledger-operating-playbook.md`
- `.crux/docs/chart-of-accounts-guide.md`

---

## Step 5 — Review & Confirm

Summarise:
- hledger MCP availability
- journal mode
- default report period
- reporting currency
- report granularity

---

## Step 6 — Finalise

1. Write collected durable facts to `.crux/workspace/ledger-finance-manager/MEMORY.md`
2. Update agent status to `onboarded`
3. Broadcast `agent.onboarded`
4. Notify user that `@ledger-finance-manager` is ready
