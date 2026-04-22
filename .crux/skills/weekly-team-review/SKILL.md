---
name: weekly-team-review
description: >
  Produces short weekly team review notes with progress, carry-over, blockers,
  and team health signals. Use when: the user wants a weekly summary, end-of-week
  review, carry-over note, or a quick team health view.
license: MIT
compatibility: opencode
metadata:
  owner: team-operations-coach
  type: read-write
  approval: No
---

# weekly-team-review

**Owner**: `team-operations-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns weekly team information into a short review note that is useful for next-week planning.

---

## When to Use Me

- User wants a team weekly summary
- End-of-week review is due
- Carry-over and team health should be recorded

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/team-operations-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/team-operations-principles.md      (generate from agent assets first if missing)
  .crux/docs/weekly-team-reporting-format.md    (generate from agent assets first if missing)
  {operations-root}/templates/weekly-team-review.md
  {operations-root}/weekly/

Estimated token cost: ~400 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `team-name` | user | Yes |
| `week-id` | user / system date | No — default: current week |
| `weekly-status` | user / existing weekly note | Yes |

---

## Steps

```
1. Read the relevant weekly team plan and any status updates
2. Summarise what moved and what did not
3. Record carry-over, blockers, dependencies, and team health signal
4. Keep the note short and useful for the next cycle
5. Save review output without erasing the original weekly context
6. Return a concise team review summary
7. Skill complete — unload
```

---

## Output

**Writes to**: `{operations-root}/weekly/YYYY-Www/{team-name}-review.md`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Weekly context missing | Build a conservative review from available data and mark gaps |
| Stale input detected | Flag the review as stale-sensitive |
| Unexpected failure | Stop. Write error to bus. Notify user. |
