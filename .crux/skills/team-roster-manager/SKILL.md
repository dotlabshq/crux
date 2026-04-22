---
name: team-roster-manager
description: >
  Creates and updates team cards, member cards, and ownership records under the
  operations structure. Use when: the user wants to define teams, assign leads,
  list members, clarify ownership, or refresh team and people markdown files.
license: MIT
compatibility: opencode
metadata:
  owner: team-operations-coach
  type: read-write
  approval: No
---

# team-roster-manager

**Owner**: `team-operations-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Writes or updates team and people markdown files under the selected `operations/` root.

---

## When to Use Me

- User defines teams or team leads
- Team membership needs to be recorded or updated
- Ownership areas need to be written clearly

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/team-operations-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/team-operations-principles.md            (generate from agent assets first if missing)
  .crux/docs/situational-leadership-mapping.md        (generate from agent assets first if missing)
  {operations-root}/templates/team-card.md
  {operations-root}/templates/person-card.md
  {operations-root}/teams/
  {operations-root}/people/

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `teams` | user / onboarding | Yes |
| `members` | user / onboarding | No |
| `ownership` | user | No |

---

## Steps

```
1. Read operations preferences and any existing team/member files
2. Create or update a team card for each named team
3. If member tracking is enabled, create or update person cards for named members
4. Make ownership explicit where provided
5. Keep notes short and summary-first
6. Return a concise roster update summary
7. Skill complete — unload
```

---

## Output

**Writes to**:
- `{operations-root}/teams/{team-name}.md`
- `{operations-root}/people/{person-name}.md`

**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Team exists but structure differs | Preserve existing content and update conservatively |
| Member ownership unclear | Record as unknown and mark for clarification |
| Unexpected failure | Stop. Write error to bus. Notify user. |
