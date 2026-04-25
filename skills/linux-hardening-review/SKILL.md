---
name: linux-hardening-review
description: >
  Reviews a Linux host against a practical hardening baseline including SSH,
  updates, firewall posture, and obvious exposure risks. Use when: the user
  wants a hardening review, baseline security check, or a short list of the
  highest-value host safety improvements.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: No
---

# linux-hardening-review

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces a practical Linux hardening review focused on the highest-value safety issues first.

---

## When to Use Me

- Baseline host hardening is requested
- SSH/firewall/update posture needs review
- A quick security hygiene view is needed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/linux-hardening-baseline.md
  .crux/docs/ssh-safety-checklist.md
  (generate from agent assets first if missing)

External requirement:
  SSH or local shell access if live host review is needed.

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user | Yes |
| `criticality` | user / MEMORY.md | No |

---

## Steps

```
1. Review host against practical baseline areas
2. Identify the highest-risk posture gaps
3. Separate fast fixes from approval-sensitive changes
4. Return a prioritised hardening note
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Linux Hardening Review

## Current Baseline
- ...

## Highest-Risk Gaps
- ...

## Fast Fixes
- ...

## Approval-Sensitive Changes
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Hardening evidence is partial | mark missing checks instead of assuming safe posture |
| Risk level depends on business context | state the dependency explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
