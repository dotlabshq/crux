---
name: weekly-team-planner
description: >
  Writes short weekly team plans with focus areas, owners, blockers, and risks.
  Use when: the user wants to plan a team's week, set this week's focus, or create
  weekly team notes under the operations structure.
license: MIT
compatibility: opencode
metadata:
  owner: team-operations-coach
  type: read-write
  approval: No
---

# weekly-team-planner

**Owner**: `team-operations-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Writes a short weekly plan for a team without turning it into micro-task tracking.

---

## When to Use Me

- User wants this week's team plan
- A new week starts and no team weekly note exists
- Team focus, owners, or blockers need a weekly reset

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/team-operations-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/team-operations-principles.md      (generate from agent assets first if missing)
  .crux/docs/weekly-team-reporting-format.md    (generate from agent assets first if missing)
  {operations-root}/templates/weekly-team-plan.md
  {operations-root}/teams/
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
| `focus-items` | user | Yes |
| `blockers` | user | No |

---

## Steps

```
1. Read the team card and current reporting preferences
2. Create the weekly folder for the target week if needed
3. Write a short weekly team plan:
   summary
   focus
   owners
   blockers
   dependencies
   risks
   leadership note
4. Save to the current week path
5. Return a concise planning summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `{operations-root}/weekly/YYYY-Www/{team-name}.md`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Focus items too vague | Ask for clarification or record assumptions clearly |
| Existing weekly plan exists | Merge carefully; do not overwrite silently |
| Unexpected failure | Stop. Write error to bus. Notify user. |
