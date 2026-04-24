---
name: executive-summary-writer
description: >
  Produces a concise executive summary from intake, analysis, risk, and project
  outputs. Use when: leadership needs a one-page view, the client needs a
  decision-ready summary, or multiple specialist outputs must be condensed into
  a single management note.
license: MIT
compatibility: opencode
metadata:
  owner: client-delivery-manager
  type: read-write
  approval: No
---

# executive-summary-writer

**Owner**: `client-delivery-manager`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Condenses multi-agent advisory output into a short management-ready summary.

---

## When to Use Me

- Leadership needs a one-page view
- A client-ready executive note is needed
- Multiple specialist outputs must be consolidated

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/client-delivery-manager/MEMORY.md

Loads during execution (lazy):
  .crux/docs/advisory-reporting-format.md

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `analysis-pack` | user / orchestrated outputs | Yes |
| `audience` | user | No |

---

## Steps

```
1. Read the analysis pack
2. Extract:
   client profile
   likely opportunity areas
   main risks
   next actions
3. Write output to docs/advisory/delivery/{client-or-date}-executive-summary.md
4. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/delivery/{client-or-date}-executive-summary.md`
**Format**: `markdown`

```markdown
# Executive Summary

## Client Profile

## Opportunity Areas

## Main Risks

## Recommended Next Step
```

---

## Error Handling

| Condition | Action |
|---|---|
| Inputs too detailed | compress to top decision points only |
| Inputs conflict | note the conflict explicitly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
