---
name: ci-pipeline-implementation
description: >
  Implements or refactors CI/CD pipeline configuration while respecting existing
  release gates and platform boundaries. Use when: the user wants CI changes,
  build pipeline work, or delivery automation updates.
license: MIT
compatibility: opencode
metadata:
  owner: platform-engineer
  type: read-write
  approval: No
---

# ci-pipeline-implementation

**Owner**: `platform-engineer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Guides CI/CD changes with attention to delivery behaviour, release gates, and platform safety.

---

## When to Use Me

- User wants CI/CD changes
- Build or release automation should be added or improved
- Pipeline config is part of a platform task

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/platform-engineer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/platform-principles.md              (generate from agent assets first if missing)
  .crux/docs/deployment-safety-guidelines.md     (generate from agent assets first if missing)
  .crux/docs/platform.md                         (generate during onboarding if missing and needed)

Estimated token cost: ~400 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `change-request` | user | Yes |
| `target-pipeline` | user / analysis | No |

---

## Steps

```
1. Read the relevant CI/CD config and current release flow
2. Identify delivery impact and release-gate implications
3. Implement or refactor conservatively
4. Surface validation and rollback expectations
5. Return a short pipeline change summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `pipeline and related platform files as needed`
**Format**: `source files`

---

## Error Handling

| Condition | Action |
|---|---|
| Target pipeline is unclear | Ask for clarification or narrow the likely paths |
| Production rollout impact is broad | Surface risk before editing |
| Unexpected failure | Stop. Write error to bus. Notify user. |
