---
name: program-landscape-scan
description: >
  Produces a categorized landscape scan of relevant support routes for a client
  case without claiming confirmed eligibility. Use when: leadership needs a
  broad opportunity map, multiple support categories must be compared, or the
  team needs a first orientation before deeper review.
license: MIT
compatibility: opencode
metadata:
  owner: incentive-program-analyst
  type: read-write
  approval: No
---

# program-landscape-scan

**Owner**: `incentive-program-analyst`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Creates a broad support-landscape view grouped by category, target, likely value, and effort.

---

## When to Use Me

- Leadership wants an opportunity map
- Multiple support families must be compared
- The case is still exploratory and needs a broad first view

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/incentive-program-analyst/MEMORY.md

Loads during execution (lazy):
  .crux/docs/incentive-program-catalog.md
  .crux/docs/sector-support-patterns.md

Estimated token cost: ~550 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `client-profile` | user / lead-intake-triage | Yes |
| `focus-area` | user | No |

---

## Steps

```
1. Read the client profile
2. Group opportunity space by support family
3. Rank by likely fit, value, and effort
4. Write output to docs/advisory/analysis/{client-or-date}-program-landscape.md
5. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/analysis/{client-or-date}-program-landscape.md`
**Format**: `markdown`

```markdown
# Program Landscape Scan

| Category | Likely Fit | Potential Value | Effort | Notes |
|---|---|---|---|---|
```

---

## Error Handling

| Condition | Action |
|---|---|
| Case too early-stage | keep output broad and assumption-led |
| Focus area missing | scan all major support families briefly |
| Unexpected failure | Stop. Write error to bus. Notify user. |
