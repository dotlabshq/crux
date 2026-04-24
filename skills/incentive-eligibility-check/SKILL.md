---
name: incentive-eligibility-check
description: >
  Produces a preliminary fit analysis across relevant incentives and support
  programs using the client profile. Use when: the user asks which programs may
  fit, a specialist needs a first-pass incentive screen, or multiple support
  tracks need a cautious pre-evaluation.
license: MIT
compatibility: opencode
metadata:
  owner: incentive-program-analyst
  type: read-write
  approval: No
---

# incentive-eligibility-check

**Owner**: `incentive-program-analyst`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Builds a preliminary incentive-fit view with likely programs, fit level, gaps, risks, and next actions.

---

## When to Use Me

- The client wants to know which incentives may fit
- A shortlist of likely support programs is needed
- A cautious preliminary evaluation should be documented

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/incentive-program-analyst/MEMORY.md

Loads during execution (lazy):
  .crux/docs/incentive-program-catalog.md
  .crux/docs/incentive-screening-rules.md

Estimated token cost: ~650 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `client-profile` | user / lead-intake-triage | Yes |
| `project-description` | user | No |

---

## Steps

```
1. Read the client profile
2. Compare it against likely-fit support tracks
3. Classify each as likely-fit / partial-fit / low-fit
4. State missing conditions and required follow-up
5. Write output to docs/advisory/analysis/{client-or-date}-incentive-fit.md
6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/analysis/{client-or-date}-incentive-fit.md`
**Format**: `markdown`

```markdown
# Preliminary Incentive Fit Analysis

| Program | Fit | Why It May Fit | Missing Conditions | Risks |
|---|---|---|---|---|
```

---

## Error Handling

| Condition | Action |
|---|---|
| Client profile incomplete | mark assumptions and missing data explicitly |
| Program choice too broad | return shortlist-first output |
| Unexpected failure | Stop. Write error to bus. Notify user. |
