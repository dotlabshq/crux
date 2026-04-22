---
name: weekly-review-writer
description: >
  Writes a personal weekly review note from the user's task and planning history.
  Covers what was completed, what carried over, blockers, and intentions for the
  coming week. Use when: the user wants a weekly review, end-of-week reflection,
  carry-over summary, or a weekly note to close the week and plan the next one.
license: MIT
compatibility: opencode
metadata:
  owner: personal-productivity-coach
  type: read-write
  approval: No
---

# weekly-review-writer

**Owner**: `personal-productivity-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Writes a personal weekly review note: what moved, what did not, what carries over,
and a short intention for the coming week. Saves it as a weekly markdown note
that works well in Obsidian or any plain text editor.

---

## When to Use Me

- User asks for a weekly review or end-of-week note
- The week is ending and carry-over should be captured
- User wants a short reflection before planning the next week
- A weekly note should be created from existing daily notes or a task summary

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/personal-productivity-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/personal-planning-formats.md    (generate from agent assets first if missing)
  {notes-root}/Templates/Weekly Review.md
  {notes-root}/Daily Notes/                  load-when: daily notes for this week exist
  {notes-root}/Weekly Notes/

Estimated token cost: ~400 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `week-id` | user / system date | No — default: current week (ISO 8601: YYYY-Www) |
| `weekly-summary` | user / existing daily notes | No — auto-loaded from daily notes if present |
| `carry-over-items` | user / previous weekly note | No — auto-loaded from last weekly note if present |

---

## Steps

```
1. Determine the target week from week-id or current date
2. Load any daily notes for this week from {notes-root}/Daily Notes/
   IF daily notes exist → extract completed items, carry-over candidates, blockers
   IF daily notes missing → ask user for a brief status summary instead
3. Load the previous weekly note if it exists → extract open items
4. Build the review structure:
   completed        — what actually moved this week
   carry-over       — what did not finish and moves to next week
   blockers         — anything that stopped progress (still open or resolved)
   reflections      — optional: what went well, what was friction
   next-week        — short intention note for the coming week (max 3 items)
5. Respect MEMORY.md preferences:
   separate-work-and-personal → split sections if true
   preferred-output-format    → apply if weekly applies
6. Write note to:
   {notes-root}/Weekly Notes/YYYY-Www.md
   IF a weekly template exists → follow it, do not overwrite the template itself
7. Skill complete — unload
```

---

## Output

**Writes to**: `{notes-root}/Weekly Notes/YYYY-Www.md`
**Format**: `markdown`

```markdown
# Weekly Review — YYYY-Www

## Completed
- ...

## Carry-Over
- ...

## Blockers
- ...

## Reflections
- ...

## Next Week — Intentions
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| No daily notes and no user summary | Ask for a brief status before writing; do not fabricate |
| Weekly note already exists | Append or merge carefully; do not overwrite silently |
| Carry-over list is very long | Surface the top 3 and note the rest as "backlog" |
| Unexpected failure | Stop. Write error to bus. Notify user. |

---

## Example Output

```markdown
# Weekly Review — 2026-W17

## Completed
- Drafted proposal for Q2 project
- Cleared inbox backlog (28 items)
- Attended team sync and followed up on two open items

## Carry-Over
- Review vendor contract (waiting for legal)
- Write up retrospective notes from Tuesday's session

## Blockers
- Access to staging environment still pending from infra team

## Reflections
- Deep work sessions on Mon/Tue were productive; fragmented afternoon slots were not
- Task list was too ambitious; top-3 discipline helped

## Next Week — Intentions
- Finish vendor contract review before Wednesday
- Block 2h focus slots each morning
- Draft personal OKR for Q3
```
