---
name: today-plan-writer
description: >
  Writes a practical daily plan from a triaged task list. Produces a short markdown
  note with top priorities, quick wins, waiting items, and optional follow-ups.
  Use when: the user asks for a daily plan, today's priorities, or a daily note from
  an existing task list or triage result.
license: MIT
compatibility: opencode
metadata:
  owner: personal-productivity-coach
  type: read-write
  approval: No
---

# today-plan-writer

**Owner**: `personal-productivity-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Converts triage results into a realistic day plan and writes it as a daily markdown note.

---

## When to Use Me

- User asks for a daily plan
- Triage is complete and a focused today note is needed
- A daily note should be generated from current priorities

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/personal-productivity-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/personal-planning-formats.md (generate from agent assets first if missing)
  {notes-root}/Templates/Daily Note.md
  {notes-root}/Daily Notes/

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `triage-result` | task-triage / user | Yes |
| `date` | user / system date | No — default: today |
| `plan-style` | MEMORY.md / user | No |

---

## Steps

```
1. Read triage result and planning preferences
2. Select:
   top priorities
   quick wins
   waiting items
   if-time-allows items
3. Keep top priorities realistic by default
4. Write note to:
   {notes-root}/Daily Notes/YYYY-MM-DD.md
5. If a daily template exists, follow it instead of replacing it
6. Skill complete — unload
```

---

## Output

**Writes to**: `{notes-root}/Daily Notes/YYYY-MM-DD.md`
**Format**: `markdown`

```markdown
# Daily Note

## Top Priorities
- ...

## Quick Wins
- ...

## Waiting / Follow-Up
- ...

## If Time Allows
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Triage result too vague | Ask for clarification or use follow-up-questioner |
| Daily note already exists | Append or merge carefully; do not overwrite silently |
| Unexpected failure | Stop. Write error to bus. Notify user. |
