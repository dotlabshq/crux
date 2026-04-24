---
name: eligibility-matrix-builder
description: >
  Converts a client case and target support path into a structured preliminary
  eligibility matrix. Use when: a case needs fit shown as suitable / partial /
  unsuitable, missing conditions must be made explicit, or a review should be
  turned into a decision-ready matrix.
license: MIT
compatibility: opencode
metadata:
  owner: eligibility-risk-analyst
  type: read-write
  approval: No
---

# eligibility-matrix-builder

**Owner**: `eligibility-risk-analyst`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Builds a preliminary eligibility matrix with criteria, status, evidence gaps, and action items.

---

## When to Use Me

- A support path needs a structured fit matrix
- Management wants a criteria-based review
- Partial fit and missing conditions must be made explicit

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/eligibility-risk-analyst/MEMORY.md

Loads during execution (lazy):
  .crux/docs/eligibility-review-framework.md

Estimated token cost: ~500 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `case-summary` | user / incentive-eligibility-check | Yes |
| `target-program` | user | Yes |

---

## Steps

```
1. Read case summary and target program
2. List core fit criteria
3. Mark each as met / partial / unmet / unknown
4. Write output to docs/advisory/risk/{client-or-date}-eligibility-matrix.md
5. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/risk/{client-or-date}-eligibility-matrix.md`
**Format**: `markdown`

```markdown
# Preliminary Eligibility Matrix

| Criterion | Status | Evidence | Gap | Action |
|---|---|---|---|---|
```

---

## Error Handling

| Condition | Action |
|---|---|
| Criteria unclear | state assumptions explicitly |
| Evidence missing | mark as unknown, not failed |
| Unexpected failure | Stop. Write error to bus. Notify user. |
