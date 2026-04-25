---
name: linux-user-access-review
description: >
  Reviews Linux users, groups, sudo posture, and SSH access hygiene. Use when:
  the user wants to inspect who has access, whether sudo is too broad, whether
  SSH keys look stale, or whether baseline user-access hygiene is acceptable.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: No
---

# linux-user-access-review

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces an access-focused Linux review covering local users, groups, sudo patterns, and SSH key hygiene.

---

## When to Use Me

- User wants access review
- Sudo or SSH key posture is unclear
- Host access hygiene should be assessed before changes

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/linux-hardening-baseline.md   (generate from agent assets first if missing)

External requirement:
  SSH or local shell access if host evidence must be gathered live.

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user | Yes |
| `focus` | user | No — users / sudo / ssh-keys / full-review |

---

## Steps

```
1. Confirm target host and review scope
2. Inspect user, group, sudo, and SSH access state as relevant
3. Highlight overly broad access, stale accounts, and risky key posture
4. Return findings with safe next steps
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Linux Access Review

## Current Posture
- ...

## Risks
- ...

## Suggested Fixes
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Host access data is incomplete | state evidence gap explicitly |
| Review suggests policy issue beyond host hygiene | escalate to compliance-governance-lead |
| Unexpected failure | Stop. Write error to bus. Notify user. |
