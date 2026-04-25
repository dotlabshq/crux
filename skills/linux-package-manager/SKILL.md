---
name: linux-package-manager
description: >
  Plans or performs package installation, upgrade, removal, and repository-aware
  Linux package actions with service impact awareness. Use when: the user wants
  to install tools, patch packages, remove software, review package state, or
  understand the risk of a package change on a Linux host.
license: MIT
compatibility: opencode
metadata:
  owner: linux-admin
  type: read-write
  approval: Yes
---

# linux-package-manager

**Owner**: `linux-admin`
**Type**: `read-write`
**Approval**: `Yes`

---

## What I Do

Handles Linux package actions with explicit awareness of package manager family, service impact, and verification after change.

---

## When to Use Me

- Install a package
- Patch or upgrade packages
- Remove a package
- Review whether package action is safe

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/linux-admin/MEMORY.md

Loads during execution (lazy):
  .crux/docs/linux-operations-principles.md
  .crux/docs/linux-hardening-baseline.md
  (generate from agent assets first if missing)

External requirement:
  SSH or local shell access to the target host.

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-host` | user | Yes |
| `package-action` | user | Yes — install / upgrade / remove / inspect |
| `package-name` | user | Yes |
| `package-manager` | user / detection | No |

---

## Steps

```
1. Detect or confirm package manager family
2. Inspect current package state and likely reverse dependencies if relevant
3. State service or reboot risk if applicable
4. For mutating actions, wait for approval
5. Execute approved package action
6. Verify package and related service state
7. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Package Action

## Current State
- ...

## Planned Change
- ...

## Risk
- ...

## Verification
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Package manager unclear | detect distro family before acting |
| Package not found | report repository or naming mismatch |
| Unexpected failure | Stop. Write error to bus. Notify user. |
