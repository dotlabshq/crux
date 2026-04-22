---
name: task-capture-normaliser
description: >
  Cleans up messy task input before triage. Splits mixed notes into task candidates,
  removes obvious duplicates, and separates reminders, ideas, and actionable items.
  Use when: the user pastes a rough note dump, a mixed inbox list, meeting leftovers,
  or a stream-of-consciousness task list that needs structure before prioritisation.
license: MIT
compatibility: opencode
metadata:
  owner: personal-productivity-coach
  type: read-write
  approval: No
---

# task-capture-normaliser

**Owner**: `personal-productivity-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Normalises unstructured notes into cleaner task candidates that are easier to triage.

---

## When to Use Me

- User pasted a messy note dump
- A list mixes tasks, reminders, thoughts, and duplicates
- Triage quality depends on input cleanup first

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/personal-productivity-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/task-triage-principles.md   (generate from agent assets first if missing)
  {notes-root}/00 Inbox/

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `raw-input` | user | Yes |
| `save-location` | user / MEMORY.md | No — default: {notes-root}/00 Inbox/ |

---

## Steps

```
1. Split raw input into candidate lines or bullet items
2. Remove obvious duplicates and merge near-duplicates when safe
3. Classify each line as one of:
   task
   reminder
   idea
   waiting
   unclear
4. Write a cleaned capture note to:
   {notes-root}/00 Inbox/{date}-capture.md
5. Return the cleaned list for downstream triage
6. Skill complete — unload
```

---

## Output

**Writes to**: `{notes-root}/00 Inbox/{date}-capture.md`
**Format**: `markdown`

```markdown
# Capture

## Tasks
- ...

## Waiting
- ...

## Ideas
- ...

## Needs Clarification
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Input too short to classify | Return as-is and note minimal cleanup |
| Duplicate ambiguity | Keep both and mark for clarification |
| Unexpected failure | Stop. Write error to bus. Notify user. |
