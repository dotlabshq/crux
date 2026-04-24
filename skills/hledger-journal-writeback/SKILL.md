---
name: hledger-journal-writeback
description: >
  Applies validated transaction drafts or explicit journal mutations to the
  hledger journal through MCP-backed write operations. Use when: a reviewed
  transaction draft should be appended, an entry should be replaced or removed,
  or journal maintenance needs a controlled writeback path.
license: MIT
compatibility: opencode
metadata:
  owner: ledger-finance-manager
  type: read-write
  approval: No
---

# hledger-journal-writeback

**Owner**: `ledger-finance-manager`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Executes controlled journal mutations through hledger MCP after validation, preview, and backup-aware checks.

---

## When to Use Me

- A reviewed transaction draft should be appended to the journal
- An existing entry must be replaced or removed with a clear instruction
- A validated import or rewrite should be applied

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ledger-finance-manager/MEMORY.md
    Fields needed when present:
      journal-write-mode
      default-report-period

Loads during execution (lazy):
  .crux/docs/hledger-operating-playbook.md

External requirement:
  hledger MCP configured and reachable
  Read-only mode must be disabled for write operations

Estimated token cost: ~750 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `operation` | user | Yes — add / replace / remove / import / rewrite / close-books |
| `draft-entry` | hledger-transaction-draft / user | No — required for add in most cases |
| `target-entry` | user / find_entry result | No — required for replace / remove |
| `write-options` | user | No |

---

## Steps

```
1. Resolve operation type
2. Check hledger MCP write capability:
   IF read-only mode is enabled
     → stop and report the blocker

3. Validate the intended mutation:
   add        → validate entry text
   replace    → locate exact target and validate replacement
   remove     → locate exact target and preview deletion scope
   import     → validate import source and dry-run where supported
   rewrite    → validate rewrite rule and preview affected scope
   close-books → verify accounting-period intent explicitly

4. Preview the exact change and expected affected file/entry

5. Ensure backup-aware execution:
   IF backup skip is disabled
     → proceed with normal protected write
   ELSE
     → state that backup is disabled before execution

6. Execute through hledger MCP

7. Write output to docs/finance/YYYY-MM-DD-journal-writeback.md

8. Return:
   operation
   affected entry or file
   result
   follow-up checks

9. Skill complete — unload
```

---

## Output

**Writes to**: `docs/finance/YYYY-MM-DD-journal-writeback.md`
**Format**: `markdown`

```markdown
# Journal Writeback Result

## Operation

## Target

## Mutation Summary

## Result

## Follow-Up Checks
```

---

## Error Handling

| Condition | Action |
|---|---|
| hledger MCP is read-only | stop and report writeback blocker |
| Target entry not found | stop and return no-change result |
| Historical rewrite intent ambiguous | stop and ask user to clarify intent |
| Validation fails | do not execute writeback |
| Unexpected failure | Stop. Write error to bus. Notify user. |
