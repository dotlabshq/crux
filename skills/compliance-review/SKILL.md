---
name: compliance-review
description: >
  Reviews a support, grant, investment, or advisory file for statement,
  documentation, compliance, and audit risk. Use when: a file is ready for risk
  review, the team needs a control-oriented quality gate, or leadership wants a
  concise risk table before submission or client delivery.
license: MIT
compatibility: opencode
metadata:
  owner: eligibility-risk-analyst
  type: read-write
  approval: No
---

# compliance-review

**Owner**: `eligibility-risk-analyst`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns a draft advisory file into a risk review covering statement, evidence, compliance, and audit concerns.

---

## When to Use Me

- A draft file needs a risk gate before delivery
- A support application should be reviewed for weak statements or missing support
- Leadership wants a concise risk-and-control summary

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/eligibility-risk-analyst/MEMORY.md

Loads during execution (lazy):
  .crux/docs/risk-review-checklist.md
  .crux/docs/document-requirements-reference.md

Estimated token cost: ~550 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `draft-file` | user / specialist output | Yes |
| `target-context` | user | No |

---

## Steps

```
1. Read the draft file
2. Review for:
   statement risk
   missing documents
   compliance mismatch
   privacy/confidentiality issues
   audit and commitment risk
3. Rate risk severity and propose controls
4. Write output to docs/advisory/risk/{client-or-date}-compliance-review.md
5. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/risk/{client-or-date}-compliance-review.md`
**Format**: `markdown`

```markdown
# Compliance Review

| Risk | Severity | Explanation | Impact | Recommended Control |
|---|---|---|---|---|
```

---

## Error Handling

| Condition | Action |
|---|---|
| Draft too incomplete | mark review as preliminary only |
| Source evidence missing | downgrade confidence and state gap |
| Unexpected failure | Stop. Write error to bus. Notify user. |
