---
name: transformation-roadmap-advisor
description: >
  Converts a transformation goal into a phased roadmap with practical sequencing,
  pilot scope, and scale criteria. Use when: the user wants to know what to do
  first, how to move from pilot to rollout, how to phase an AI or platform
  change, or how to avoid trying to transform everything at once.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# transformation-roadmap-advisor

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Builds a practical roadmap that starts small, proves value, and only then expands scope.

---

## When to Use Me

- "What should we do first?"
- A transformation idea needs phases
- The user wants a pilot-to-scale path
- AI or process change needs a realistic roadmap

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ai-transformation-principles.md  (generate from agent assets first if missing)
  .crux/docs/executive-brief-format.md        (generate from agent assets first if missing)

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `goal` | user | Yes |
| `current-state` | user | No |
| `constraints` | user | No |
| `time-horizon` | user | No |

---

## Steps

```
1. Define the target outcome in business terms
2. Identify the smallest pilot worth running
3. Break the path into phases: prove, stabilise, scale
4. Attach simple success criteria to each phase
5. State what should not be done yet
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Transformation Roadmap

## Goal
- ...

## Phase 1 — Prove
- ...

## Phase 2 — Stabilise
- ...

## Phase 3 — Scale
- ...

## Not Yet
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Goal is too broad | reduce it to one transformation outcome first |
| Roadmap depends on missing constraints | state the assumption before sequencing |
| Unexpected failure | Stop. Write error to bus. Notify user. |
