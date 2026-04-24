---
name: missing-info-questioner
description: >
  Produces short, high-value clarification questions for advisory intake when
  critical client facts are missing. Use when: the client brief is incomplete,
  support path selection is blocked, or the team needs a concise list of
  missing details before continuing.
license: MIT
compatibility: opencode
metadata:
  owner: advisory-orchestrator
  type: read-write
  approval: No
---

# missing-info-questioner

**Owner**: `advisory-orchestrator`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns advisory intake gaps into a short, prioritized clarification list.

---

## When to Use Me

- Critical intake fields are missing
- Service-line selection is blocked by incomplete facts
- The user needs concise next questions, not a long questionnaire

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/advisory-orchestrator/MEMORY.md

Loads during execution (lazy):
  .crux/docs/advisory-intake-principles.md

Estimated token cost: ~250 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `intake-summary` | lead-intake-triage / user | Yes |
| `max-questions` | user / MEMORY.md | No |

---

## Steps

```
1. Read intake summary and missing fields
2. Rank questions by decision impact
3. Keep wording short and business-friendly
4. Write output to docs/advisory/intake/{client-or-date}-missing-info.md
5. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/intake/{client-or-date}-missing-info.md`
**Format**: `markdown`

```markdown
# Missing Information

## Critical Questions
- ...

## Why These Matter
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| No clear gaps found | return "no critical gaps identified" |
| Intake summary inconsistent | surface the contradiction explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
