---
name: advisory-roadmap-writer
description: >
  Builds a practical 30/60/90 day advisory roadmap from intake, specialist
  outputs, and current blockers. Use when: the user wants a phased action plan,
  leadership needs an implementation view, or an advisory case must be turned
  into next steps with owners and risks.
license: MIT
compatibility: opencode
metadata:
  owner: advisory-orchestrator
  type: read-write
  approval: No
---

# advisory-roadmap-writer

**Owner**: `advisory-orchestrator`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns advisory analysis into a phased 30/60/90 day plan with priorities, dependencies, and risks.

---

## When to Use Me

- The user wants a 30/60/90 day plan
- Specialist analysis is ready and needs orchestration
- Management needs next steps, not only diagnosis

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/advisory-orchestrator/MEMORY.md

Loads during execution (lazy):
  .crux/docs/advisory-reporting-format.md
  docs/advisory/intake/

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `case-summary` | user / specialist outputs | Yes |
| `current-risks` | user / specialist outputs | No |

---

## Steps

```
1. Read current case summary
2. Group actions into first 30, next 30, and following 30 days
3. Mark owners, blockers, and prerequisites
4. Write output to docs/advisory/roadmaps/{client-or-date}-30-60-90.md
5. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/roadmaps/{client-or-date}-30-60-90.md`
**Format**: `markdown`

```markdown
# 30/60/90 Day Advisory Roadmap

## First 30 Days

## Days 31-60

## Days 61-90

## Risks And Dependencies
```

---

## Error Handling

| Condition | Action |
|---|---|
| Inputs too vague | produce assumptions explicitly |
| No phased plan possible | write blockers-first roadmap |
| Unexpected failure | Stop. Write error to bus. Notify user. |
