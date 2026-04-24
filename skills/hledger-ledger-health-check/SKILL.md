---
name: hledger-ledger-health-check
description: >
  Reviews ledger quality, account structure, payee consistency, file layout,
  and mutation safety posture using hledger reporting and journal metadata. Use
  when: the user wants to know whether the books are structurally healthy, the
  chart of accounts is drifting, journals need cleanup priorities, or writeback
  operations should be preceded by a health check.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-only
  approval: No
---

# hledger-ledger-health-check

**Owner**: `ledger-finance-manager`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Checks ledger structure, reporting consistency, and journal hygiene to surface cleanup and control priorities.

---

## When to Use Me

- User asks if the ledger is clean or well-structured
- A writeback workflow should start from a health review
- Leadership wants finance operations cleanup priorities

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/chart-of-accounts-guide.md
  .crux/docs/hledger-operating-playbook.md

External requirement:
  hledger MCP configured and reachable

Estimated token cost: ~600 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `scope` | user | No — full ledger by default |
| `period` | user | No |

---

## Steps

```
1. Inspect accounts, files, payees, descriptions, tags, and stats via hledger MCP
2. Look for:
   unbalanced or suspicious patterns
   account sprawl
   inconsistent payees/descriptions
   weak tagging or memo practices
   reporting ambiguity
3. Rank cleanup priorities by impact
4. Write output to docs/finance/YYYY-MM-DD-ledger-health.md when a saved report is useful
5. Return a concise health summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-ledger-health.md` when requested
**Format**: `markdown`

```markdown
# Ledger Health Check

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
| Ledger metadata incomplete | state visibility limitation explicitly |
| Stats not available | continue with partial health review |
| Unexpected failure | Stop. Write error to bus. Notify user. |
