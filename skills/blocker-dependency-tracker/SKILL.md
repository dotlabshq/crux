---
name: blocker-dependency-tracker
description: >
  Collects blockers, dependencies, and ownership gaps from team notes and turns
  them into a short visible report. Use when: the user wants blocker visibility,
  dependency review, escalation candidates, or a cross-team coordination view.
license: MIT
compatibility: opencode
metadata:
  owner: team-operations-coach
  type: read-write
  approval: No
---

# blocker-dependency-tracker

**Owner**: `team-operations-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Surfaces blockers, dependencies, and unclear ownership as a short coordination report.

---

## When to Use Me

- User asks what is blocked
- Cross-team dependency visibility is needed
- Ownership gaps or escalation items need to be listed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/team-operations-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/team-operations-principles.md      (generate from agent assets first if missing)
  .crux/docs/weekly-team-reporting-format.md    (generate from agent assets first if missing)
  {operations-root}/weekly/
  {operations-root}/reports/

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `scope` | user | No — default: all tracked teams |
| `week-id` | user / system date | No — default: current week |

---

## Steps

```
1. Read weekly notes across the requested scope
2. Extract blockers, dependencies, and ownership gaps
3. Group them by team and severity
4. Write a short blocker report if user wants a saved output
5. Return a concise coordination summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `{operations-root}/reports/YYYY-Www-blockers.md` when requested
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| No blockers found | Return "no major blockers found" and note reporting scope |
| Ownership missing | Mark as unresolved ownership rather than guessing |
| Unexpected failure | Stop. Write error to bus. Notify user. |
