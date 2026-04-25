---
name: ai-usecase-prioritiser
description: >
  Identifies and ranks practical AI opportunities based on value, effort, data
  readiness, and operating risk. Use when: the user asks where AI should be used,
  which pilot should come first, or how to avoid vague AI strategy work without
  a realistic starting point.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# ai-usecase-prioritiser

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Ranks AI use cases by practical fit so the user can start with a small, testable pilot
instead of a broad transformation promise.

---

## When to Use Me

- "Where should we use AI?"
- "What should we pilot first?"
- A company wants AI ideas ranked by business reality

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ai-transformation-principles.md  (generate from agent assets first if missing)

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `company-context` | user | Yes |
| `candidate-processes` | user | No |
| `constraints` | user / MEMORY.md | No |

---

## Steps

```
1. Identify the core business bottlenecks or repetitive work
2. Propose candidate AI use cases if the user did not provide them
3. Score each candidate using value, effort, data readiness, adoption friction, and risk
4. Recommend one primary pilot and one secondary option
5. Explain why the top choice is the right starting point
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# AI Use-Case Priorities

| Use Case | Value | Effort | Risk | Why It Fits |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

## Recommended First Pilot
- ...

## Why
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Company context is too thin | ask for sector, team size, process pain, and data availability |
| Too many speculative ideas | keep only the top 3 realistic options |
| Unexpected failure | Stop. Write error to bus. Notify user. |
