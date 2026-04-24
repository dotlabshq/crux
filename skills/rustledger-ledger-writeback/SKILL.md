---
name: rustledger-ledger-writeback
description: >
  Applies validated Beancount transaction drafts or explicit file mutations to a
  rustledger-backed ledger, then re-validates and formats the file. Use when: a
  reviewed draft should be appended, a mutation to a Beancount ledger is
  intended, or rustledger-based books must be updated in a controlled way.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-write
  approval: No
---

# rustledger-ledger-writeback

**Owner**: `ledger-finance-manager`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Applies controlled Beancount ledger mutations, then validates and formats the ledger with rustledger.

---

## When to Use Me

- A validated Beancount transaction draft should be appended
- A ledger mutation is needed in a rustledger environment
- Beancount file changes should be followed by check/format validation

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/rustledger-operating-playbook.md

External requirement:
  rustledger CLI installed and reachable
  Expected command family:
    rledger check
    rledger format

Estimated token cost: ~700 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `ledger-file` | user / MEMORY.md | Yes |
| `operation` | user | Yes — append / replace / remove |
| `draft-transaction` | rustledger-transaction-draft / user | No — required for append in most cases |
| `target-range` | user | No — required for replace / remove |

---

## Steps

```
1. Validate target ledger path
2. Preview the exact text mutation
3. Create or confirm a backup-aware recovery path
4. Apply the mutation to the Beancount file
5. Run:
   rledger check {ledger-file}
   rledger format {ledger-file}
6. If validation fails:
   stop and report failure, preserving recovery path
7. Write output to docs/finance/YYYY-MM-DD-rustledger-writeback.md
8. Return mutation summary and follow-up checks
9. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-rustledger-writeback.md`
**Format**: `markdown`

```markdown
# Rustledger Writeback Result

## Operation

## Target File

## Mutation Summary

## Validation Result

## Follow-Up Checks
```

---

## Error Handling

| Condition | Action |
|---|---|
| Ledger file missing | stop and report path issue |
| rustledger check fails after mutation | stop and report validation failure with recovery path |
| Replace/remove target ambiguous | stop and require precise target |
| Unexpected failure | Stop. Write error to bus. Notify user. |
