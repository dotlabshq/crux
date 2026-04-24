---
name: lead-intake-triage
description: >
  Converts a raw client request into a structured advisory intake summary with
  company profile fields, explicit assumptions, missing information, and likely
  service lines. Use when: a new lead arrives, a meeting note must become a
  clean advisory brief, or a messy request must be classified before routing.
license: MIT
compatibility: opencode
metadata:
  owner: advisory-orchestrator
  type: read-write
  approval: No
---

# lead-intake-triage

**Owner**: `advisory-orchestrator`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns an incoming client request into a structured intake note and routing-ready summary.

---

## When to Use Me

- A new client request arrives
- A meeting note or email must become a structured case
- Advisory routing should start from a clean intake summary

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/advisory-orchestrator/MEMORY.md

Loads during execution (lazy):
  .crux/docs/advisory-intake-principles.md

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `client-brief` | user / meeting note / email | Yes |
| `source-channel` | user | No |

---

## Steps

```
1. Read the raw brief
2. Extract profile fields:
   sector, headcount, turnover, city, export status, investment intent, R&D direction
3. Mark unknown fields as missing rather than guessing
4. Suggest likely service lines
5. Write output to docs/advisory/intake/{client-or-date}-intake.md
6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/intake/{client-or-date}-intake.md`
**Format**: `markdown`

```markdown
# Advisory Intake Summary

## Request Summary

## Client Profile

## Missing Information

## Likely Service Lines

## Assumptions
```

---

## Error Handling

| Condition | Action |
|---|---|
| Brief too vague | produce intake note focused on missing information |
| Client identity unclear | mark client name as pending |
| Unexpected failure | Stop. Write error to bus. Notify user. |
