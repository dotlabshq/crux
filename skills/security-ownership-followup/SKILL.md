---
name: security-ownership-followup
description: >
  Clarifies ownership, next action, dependency, and follow-up date for open
  cybersecurity issues using practical CISO and monkey-management logic. Use
  when: issues are stuck, everyone thinks security owns everything, or a short
  action-oriented follow-up note is needed.
license: MIT
compatibility: opencode
metadata:
  owner: ciso-advisor
  type: read-write
  approval: No
---

# security-ownership-followup

**Owner**: `ciso-advisor`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Stop unresolved cybersecurity work from staying vaguely “with security” by assigning the next action to the correct owner.

---

## When to Use Me

- An issue is blocked or ownerless
- Security is carrying work that belongs elsewhere
- Management needs a short ownership and follow-up view

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ciso-advisor/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ciso-communication-principles.md

Estimated token cost: ~250 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `open-issue` | user / prior analysis | Yes |
| `current-owner` | user | No |

---

## Steps

```
1. Identify whose monkey the issue is
2. Define next action, owner, dependency, and follow-up date
3. Keep language short and non-blaming
4. Return a practical ownership note
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
| Ownership is genuinely shared | Split action by workstream, not by vague joint ownership |
| Follow-up date is unknown | State urgency band and require a date |
| Unexpected failure | Stop. Write error to bus. Notify user. |
