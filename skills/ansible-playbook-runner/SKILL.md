---
name: ansible-playbook-runner
description: >
  Plans or executes Ansible playbooks with explicit scope, check-mode, diff,
  and rollout posture. Use when: the user wants to run a playbook, validate a
  rollout through Ansible, apply configuration to one or more Linux hosts, or
  convert manual Linux operations into a repeatable playbook path.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: Yes
---

# ansible-playbook-runner

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `Yes`

---

## What I Do

Runs or prepares Ansible playbook execution with explicit inventory scope, safer defaults, and verification expectations.

---

## When to Use Me

- User wants to run an Ansible playbook
- Fleet configuration should be applied safely
- A manual Linux fix should become repeatable through Ansible

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ansible-execution-guidelines.md
  .crux/docs/linux-operations-principles.md
  (generate from agent assets first if missing)

External requirement:
  ansible-playbook must be available and inventory/playbook paths must be reachable.

Estimated token cost: ~650 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `inventory-path` | user / MEMORY.md | Yes |
| `playbook-path` | user | Yes |
| `target-scope` | user | No |
| `run-mode` | user | No — default: check |

---

## Steps

```
1. Confirm inventory path, playbook path, and target scope
2. Inspect inventory or rely on prior inventory review if available
3. Build safer execution shape:
   check-mode / diff / limit / tags / serial as needed
4. Before live apply:
   present exact ansible-playbook command and rollout scope
   wait for explicit approval
5. Execute approved run
6. Summarise results and follow-up verification
7. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Ansible Playbook Run

## Scope
- ...

## Execution Mode
- ...

## Result
- ...

## Follow-Up Verification
- ...
```

---

## Approval Gate

```
Before any live Ansible apply:

1. Show inventory path and target scope
2. Show playbook path
3. Show exact ansible-playbook command
4. State whether check-mode and diff were used first
5. State rollout posture: limit / serial / full scope
6. Wait for explicit approval
```

---

## Error Handling

| Condition | Action |
|---|---|
| Playbook or inventory path invalid | stop and report path issue |
| Target scope is too broad or unclear | narrow the plan before execution |
| Unexpected failure | Stop. Write error to bus. Notify user. |
