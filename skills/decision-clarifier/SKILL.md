---
name: decision-clarifier
description: >
  Turns a fuzzy request into a clear decision statement, constraints list, and
  practical recommendation frame. Use when: the real decision is buried under
  noise, stakeholders are mixing goals, the request feels over-scoped, or a
  team needs to decide what problem it is actually solving.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# decision-clarifier

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Converts a vague business or technology discussion into a concrete decision statement,
explicit constraints, and a short recommendation frame.

---

## When to Use Me

- The user asks a broad or overloaded question
- The team is talking about solutions before agreeing on the problem
- The request mixes strategy, tooling, and implementation in one bundle

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/decision-framing-patterns.md   (generate from agent assets first if missing)

Estimated token cost: ~300 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `request` | user | Yes |
| `known-constraints` | user / MEMORY.md | No |
| `target-audience` | user | No — default: operator or manager |

---

## Steps

```
1. Extract the actual decision hidden inside the request
2. Separate goals, assumptions, and constraints
3. Remove unnecessary solution detail if it is premature
4. State the main decision in one sentence
5. Return a compact recommendation frame with one next step
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Decision Frame

## Actual Decision
- ...

## Constraints
- ...

## Recommendation
- ...

## Next Step
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Request is still too vague | ask 2-3 short clarification questions |
| Constraints conflict | state the conflict explicitly and avoid premature recommendation |
| Unexpected failure | Stop. Write error to bus. Notify user. |
