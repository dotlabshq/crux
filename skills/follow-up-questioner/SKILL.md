---
name: follow-up-questioner
description: >
  Generates short clarification questions when task input is too vague for clean
  triage or planning. Use when: a task could fit multiple buckets, urgency is unclear,
  ownership is missing, or the assistant should ask before making assumptions.
license: MIT
compatibility: opencode
metadata:
  owner: personal-productivity-coach
  type: read-write
  approval: No
---

# follow-up-questioner

**Owner**: `personal-productivity-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces short, useful follow-up questions instead of guessing when the task list is ambiguous.

---

## When to Use Me

- Task urgency is unclear
- It is not clear whether something is waiting, blocked, or active
- The user likely needs a quick clarification before a clean plan is possible

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/personal-productivity-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/task-triage-principles.md   (generate from agent assets first if missing)

Estimated token cost: ~250 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `ambiguous-items` | task-triage / user | Yes |
| `max-questions` | MEMORY.md / user | No — default: 3 |

---

## Steps

```
1. Read ambiguous items
2. Write short, decision-oriented questions
3. Limit question count to avoid friction
4. Return questions in clear order
5. Optionally note unresolved items in .crux/workspace/personal-productivity-coach/NOTES.md
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
## Clarifications Needed
- Is "book dentist appointment" urgent for this week or flexible?
- Should "ask Ayse about next week's client meeting" be treated as waiting or active follow-up?
- Do you want work and personal items separated in today's plan?
```

---

## Error Handling

| Condition | Action |
|---|---|
| No meaningful ambiguity found | Return "no clarification needed" |
| Too many ambiguous items | Ask only the highest-impact questions first |
| Unexpected failure | Stop. Write error to bus. Notify user. |
