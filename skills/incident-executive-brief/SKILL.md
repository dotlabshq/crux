---
name: incident-executive-brief
description: >
  Prepares a calm executive incident brief that separates facts, assumptions,
  impact, containment status, decisions, and communication needs. Use when: an
  incident needs management framing, an executive update must be sent, or a
  customer-safe summary needs controlled wording.
license: MIT
compatibility: opencode
metadata:
  owner: ciso-advisor
  type: read-write
  approval: No
---

# incident-executive-brief

**Owner**: `ciso-advisor`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turn incident facts into a controlled executive update without overclaiming or creating unnecessary alarm.

---

## When to Use Me

- A material incident needs an executive summary
- Management wants a controlled cyber update
- An incident note needs clearer structure and calmer wording

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ciso-advisor/MEMORY.md

Loads during execution (lazy):
  .crux/docs/incident-communication-guide.md

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `incident-facts` | user / prior analysis | Yes |
| `audience` | user / MEMORY.md | No |

---

## Steps

```
1. Separate facts from assumptions
2. State business impact and operational status
3. Summarise containment, recovery, and communication needs
4. Call out any decision or sign-off requirement
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Facts are incomplete | Mark assumptions explicitly |
| Root cause is unknown | Do not force certainty |
| Unexpected failure | Stop. Write error to bus. Notify user. |
