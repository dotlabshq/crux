---
name: ssh-remote-operator
description: >
  Uses SSH for scoped remote host inspection and approved targeted changes.
  Use when: the user wants remote Linux investigation, config inspection, or a
  small host-level fix executed over SSH with explicit scope and safety notes.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: Yes
---

# ssh-remote-operator

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `Yes`

---

## What I Do

Performs remote Linux operations over SSH with an inspect-first posture and explicit approval for mutating work.

---

## When to Use Me

- Remote host inspection is needed
- A small host-level fix should be applied over SSH
- The user wants exact remote commands and verified scope

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ssh-safety-checklist.md
  .crux/docs/linux-operations-principles.md
  (generate from agent assets first if missing)

External requirement:
  SSH connectivity and credentials must already exist.

Estimated token cost: ~600 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user | Yes |
| `remote-user` | user / MEMORY.md | No |
| `operation` | user | Yes |
| `mutating` | derived | No |

---

## Steps

```
1. Confirm target host, remote user, and intended operation
2. Run read-only inspection first when possible
3. If mutation is required:
   show exact remote command
   state impact and recovery posture
   wait for explicit approval
4. Execute approved command with narrow scope
5. Verify resulting state
6. Return concise remote operation summary
7. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# SSH Operation Summary

## Target
- ...

## Commands Run
- ...

## Result
- ...

## Verification
- ...
```

---

## Approval Gate

```
Before any mutating SSH operation:

1. Show target host and user
2. Show exact command to be run
3. Explain likely impact
4. State recovery or rollback posture if relevant
5. Wait for explicit approval
```

---

## Error Handling

| Condition | Action |
|---|---|
| SSH authentication fails | stop and report access blocker |
| Command is broader than stated scope | stop and narrow the plan first |
| Unexpected failure | Stop. Write error to bus. Notify user. |
