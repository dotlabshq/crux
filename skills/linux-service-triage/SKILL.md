---
name: linux-service-triage
description: >
  Reviews a Linux service through systemd and logs to identify failure mode,
  restart risk, and likely next action. Use when: a service is down, flapping,
  degraded, or the user wants to know whether restart, config review, or deeper
  debugging is the right next step.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: No
---

# linux-service-triage

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns systemd and journal evidence into a clear service diagnosis and next-step recommendation.

---

## When to Use Me

- Service failed to start
- Service is restarting repeatedly
- User asks whether a restart is safe or useful

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/linux-operations-principles.md  (generate from agent assets first if missing)

External requirement:
  SSH or local shell access to inspect systemctl and journalctl output.

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user | Yes |
| `service-name` | user | Yes |
| `time-window` | user | No |

---

## Steps

```
1. Confirm host and service name
2. Inspect service status, recent logs, and failure counters
3. Identify likely failure class:
   config / dependency / permission / port / resource / crash
4. State whether restart is diagnostic, safe, risky, or insufficient
5. Return clear next action
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Service Triage

## Service State
- ...

## Likely Cause
- ...

## Restart Risk
- ...

## Recommended Next Step
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Service not found | report unit-name or package mismatch possibility |
| Logs unavailable | say what evidence is missing |
| Unexpected failure | Stop. Write error to bus. Notify user. |
