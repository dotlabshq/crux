---
name: task-triage
description: >
  Organises a task list into priorities, categories, waiting items, blocked work,
  and items needing clarification. Use when: the user asks to sort, prioritise,
  clean up, or make sense of a task list, inbox note, or mixed planning input.
license: MIT
compatibility: opencode
metadata:
  owner: personal-productivity-coach
  type: read-write
  approval: No
---

# task-triage

**Owner**: `personal-productivity-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns a list of tasks into a structured triage note with explicit active, waiting, blocked,
and unclear sections.

---

## When to Use Me

- User says "help me triage this"
- A task list needs priorities
- A messy inbox note should become an actionable plan

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/personal-productivity-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/task-triage-principles.md          (generate from agent assets first if missing)
  .crux/docs/obsidian-productivity-structure.md (generate from agent assets first if missing)
  {notes-root}/00 Inbox/
  {notes-root}/01 Projects/

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `task-list` | user / task-capture-normaliser | Yes |
| `context` | user | No |
| `target-note` | user | No — default: {notes-root}/Daily Notes or {notes-root}/00 Inbox |

---

## Steps

```
1. Read the task list and user preferences
2. Group items into:
   active
   today
   this-week
   waiting
   blocked
   personal
   work
   needs-clarification
3. Respect chosen priority framework:
   PARA       → suggest note placement as project / area / resource where useful
   simple     → keep only action buckets
   custom     → follow stored user preference
4. Write triage note to:
   {notes-root}/00 Inbox/{date}-task-triage.md
5. Return concise summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `{notes-root}/00 Inbox/{date}-task-triage.md`
**Format**: `markdown`

```markdown
# Task Triage

## Top Priorities
- ...

## This Week
- ...

## Waiting
- ...

## Blocked
- ...

## Needs Clarification
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| No clear actionable items | Create clarification-focused output |
| Mixed urgency with no date context | Use conservative prioritisation and mark assumptions |
| Unexpected failure | Stop. Write error to bus. Notify user. |
