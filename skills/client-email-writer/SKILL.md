---
name: client-email-writer
description: >
  Drafts client-facing emails for status updates, missing-document requests,
  follow-ups, and next-step coordination. Use when: the team needs a concise
  external email, a client must be asked for missing information, or process
  status should be communicated clearly.
license: MIT
compatibility: opencode
metadata:
  owner: client-delivery-manager
  type: read-write
  approval: No
---

# client-email-writer

**Owner**: `client-delivery-manager`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns advisory status and requests into concise, client-ready email drafts.

---

## When to Use Me

- A missing-document request must be sent
- The client needs a process update
- A follow-up or next-step email is needed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/client-delivery-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/client-delivery-style-guide.md

Estimated token cost: ~250 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `email-purpose` | user | Yes |
| `context-summary` | user / specialist outputs | Yes |
| `recipient-name` | user | No |

---

## Steps

```
1. Read purpose and context
2. Draft a concise subject and body
3. Keep requests explicit and next steps clear
4. Write output to docs/advisory/delivery/{client-or-date}-client-email.md
5. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/delivery/{client-or-date}-client-email.md`
**Format**: `markdown`

```markdown
# Client Email Draft

## Subject

## Body
```

---

## Error Handling

| Condition | Action |
|---|---|
| Purpose unclear | ask for the intended outcome |
| Context too thin | draft a short placeholder with assumptions |
| Unexpected failure | Stop. Write error to bus. Notify user. |
