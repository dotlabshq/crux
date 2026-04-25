---
name: linux-host-audit
description: >
  Performs a baseline Linux host inspection covering system identity, uptime,
  failed units, disk, memory, process pressure, and key runtime signals. Use
  when: a Linux host needs a health check, an operator wants a quick system
  picture, or host state must be documented before deeper troubleshooting.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: No
---

# linux-host-audit

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces a concise Linux host audit from safe inspection commands and existing operating context.

---

## When to Use Me

- User wants a Linux host health check
- A server should be profiled before changes
- A host issue needs a baseline state summary

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/linux-operations-principles.md  (generate from agent assets first if missing)

External requirement:
  SSH access to target host if remote inspection is needed.

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user / MEMORY.md | Yes |
| `connection-mode` | user | No — default: ssh |
| `focus-area` | user | No |

---

## Steps

```
1. Confirm target host and connection mode
2. Gather baseline host facts:
   os / kernel / uptime / load / disk / memory / failed units / listeners
3. Highlight unhealthy signals and obvious capacity or service pressure
4. Return a short host audit with the next investigation area if needed
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Linux Host Audit

## Host Summary
- ...

## Health Signals
- ...

## Risks
- ...

## Next Check
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Host unreachable | report connectivity blocker and stop |
| Partial inspection only | mark missing evidence explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
