---
name: cyber-risk-executive-brief
description: >
  Produces a short executive cyber risk brief that translates technical or
  operational security content into business risk, impact, recommendation,
  owner, and next step. Use when: leadership needs a concise security view, a
  report must be compressed for management, or a decision note is needed.
license: MIT
compatibility: opencode
metadata:
  owner: ciso-advisor
  type: read-write
  approval: No
---

# cyber-risk-executive-brief

**Owner**: `ciso-advisor`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Convert raw or technical security content into a short executive risk brief with clear decision language.

---

## When to Use Me

- Leadership asks for “the short version”
- A security report must become a management note
- A cyber issue needs risk, impact, owner, and next-step framing

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ciso-advisor/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ciso-communication-principles.md
  .crux/docs/risk-framing-patterns.md

Estimated token cost: ~300 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `source-content` | user / prior analysis | Yes |
| `audience` | user / MEMORY.md | No |

---

## Steps

```
1. Identify the real issue and business relevance
2. Separate fact from assumption
3. State risk, impact, recommendation, owner, and next step
4. Keep the brief short enough for management review
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Executive Summary

## Current Situation
- ...

## Risk / Impact
- ...

## Recommendation
- ...

## Owner / Next Step
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Source content is too weak | State missing facts explicitly |
| Audience is unclear | Default to senior management tone |
| Unexpected failure | Stop. Write error to bus. Notify user. |
