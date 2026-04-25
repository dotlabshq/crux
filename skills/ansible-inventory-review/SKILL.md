---
name: ansible-inventory-review
description: >
  Reviews Ansible inventory structure, targeting, host groups, variables, and
  rollout risk. Use when: the user wants to validate an inventory, check group
  design, avoid wrong-host targeting, or assess whether a playbook run is
  scoped safely before execution.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: No
---

# ansible-inventory-review

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Checks whether an Ansible inventory is understandable, correctly targeted, and safe enough to use for the intended rollout.

---

## When to Use Me

- User wants inventory validation
- Group scoping or vars are unclear
- Wrong-host targeting risk should be reduced before a run

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ansible-execution-guidelines.md  (generate from agent assets first if missing)

External requirement:
  Local access to inventory files or ansible-inventory command output.

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `inventory-path` | user / MEMORY.md | Yes |
| `target-pattern` | user | No |
| `playbook-context` | user | No |

---

## Steps

```
1. Inspect inventory structure and grouping
2. Check whether target patterns are understandable and safe
3. Review vars and host-group layout for rollout ambiguity
4. Return inventory risks and safer targeting guidance
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Ansible Inventory Review

## Inventory Shape
- ...

## Targeting Risks
- ...

## Safer Run Guidance
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Inventory path missing | ask for path or memory-backed default |
| Inventory parse fails | stop and report parse issue before any execution |
| Unexpected failure | Stop. Write error to bus. Notify user. |
