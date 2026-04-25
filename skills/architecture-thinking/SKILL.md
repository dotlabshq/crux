---
name: architecture-thinking
description: >
  Evaluates whether a proposed platform, AI, infrastructure, or systems design
  is structurally right for the problem, not just technically possible. Use
  when: the user asks how something should be set up, whether an architecture is
  too heavy, what the right platform shape is, or how to choose a scalable but
  not overbuilt design.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# architecture-thinking

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns architecture questions into a clear judgment about fit, complexity, scalability,
and what the right shape of the solution should be.

---

## When to Use Me

- "How should we set this up?"
- A proposed platform or infra design feels too heavy
- The user wants the right architecture, not just an implementation pattern
- AI platform, Kubernetes, infra, or systems shape needs a practical recommendation

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/decision-framing-patterns.md   (generate from agent assets first if missing)
  .crux/docs/cost-efficiency-heuristics.md  (generate from agent assets first if missing)

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `problem-statement` | user | Yes |
| `current-architecture` | user | No |
| `constraints` | user | No |

---

## Steps

```
1. Identify the actual system goal
2. Evaluate whether the proposed architecture matches current scale and constraints
3. Flag over-engineering, premature platform work, and missing foundational pieces
4. Recommend the simplest architecture that can survive expected growth
5. State when a bigger design would become justified
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Architecture View

## Current Need
- ...

## Recommended Shape
- ...

## Why This Fits
- ...

## What To Avoid
- ...

## Revisit Trigger
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Architecture detail is too thin | ask for scale, workload, team maturity, and constraints |
| Several architectures are viable | pick the simplest default and state the trade-off |
| Unexpected failure | Stop. Write error to bus. Notify user. |
