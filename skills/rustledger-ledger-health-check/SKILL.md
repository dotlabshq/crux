---
name: rustledger-ledger-health-check
description: >
  Validates and reviews a rustledger-compatible Beancount ledger for syntax,
  structural issues, account hygiene, and reporting readiness. Use when: the
  user wants to know whether the Beancount ledger is valid, the file should be
  checked before writeback, or cleanup priorities need to be identified.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# rustledger-ledger-health-check

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Uses rustledger validation and review tooling to surface ledger errors, structural issues, and cleanup priorities.

---

## When to Use Me

- User asks if the Beancount ledger is healthy
- The ledger should be validated before mutation
- Reporting quality issues or structure drift are suspected

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
  Useful command family:
    rledger check
    rledger doctor
    rledger format

Estimated token cost: ~550 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `ledger-file` | user / MEMORY.md | Yes |
| `scope` | user | No |

---

## Steps

```
1. Run rustledger check
2. If available, run rustledger doctor for diagnostics
3. Inspect format or structure issues when relevant
4. Rank cleanup priorities by impact
5. Write output to docs/finance/YYYY-MM-DD-rustledger-health.md when a saved report is useful
6. Return a concise health summary
7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-rustledger-health.md` when requested
**Format**: `markdown`

```markdown
# Rustledger Ledger Health Check

## Overall Status

## Findings
| Area | Severity | Observation | Recommended Action |
|---|---|---|---|

## Cleanup Priorities
```

---

## Error Handling

| Condition | Action |
|---|---|
| rustledger check fails | stop and report validation findings |
| doctor support unavailable | continue with partial health review |
| Unexpected failure | Stop. Write error to bus. Notify user. |
