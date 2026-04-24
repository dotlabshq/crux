---
name: proposal-writer
description: >
  Produces a client proposal or scope note for advisory work. Use when: a
  preliminary analysis must be turned into a service offer, leadership wants a
  clean proposal document, or a client-facing scope summary is needed before
  kickoff.
license: MIT
compatibility: opencode
metadata:
  owner: client-delivery-manager
  type: read-write
  approval: No
---

# proposal-writer

**Owner**: `client-delivery-manager`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns advisory understanding into a client-ready proposal or scope note.

---

## When to Use Me

- A service proposal must be written
- A preliminary offer or scope summary is needed
- Internal analysis must become a client-facing proposal draft

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/client-delivery-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/proposal-structure-guide.md
  .crux/docs/client-delivery-style-guide.md

Estimated token cost: ~550 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `case-summary` | user / orchestrated analysis | Yes |
| `target-client` | user | No |

---

## Steps

```
1. Read the case summary
2. Structure:
   need
   scope
   benefits
   approach
   required inputs
   timeline
   assumptions and risks
   next step
3. Write output to docs/advisory/delivery/{client-or-date}-proposal.md
4. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/delivery/{client-or-date}-proposal.md`
**Format**: `markdown`

```markdown
# Advisory Proposal

## Client Need

## Proposed Scope

## Expected Benefits

## Delivery Steps

## Required Inputs

## Estimated Timeline

## Assumptions And Risks

## Next Step
```

---

## Error Handling

| Condition | Action |
|---|---|
| Scope too vague | write a preliminary scope note with assumptions |
| Audience unclear | default to executive client audience |
| Unexpected failure | Stop. Write error to bus. Notify user. |
