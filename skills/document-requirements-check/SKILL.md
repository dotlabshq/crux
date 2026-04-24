---
name: document-requirements-check
description: >
  Produces a required-document and missing-document checklist for a target
  support path. Use when: the team needs a submission checklist, a client must
  be told which documents are missing, or dossier readiness depends on evidence
  collection.
license: MIT
compatibility: opencode
metadata:
  owner: eligibility-risk-analyst
  type: read-write
  approval: No
---

# document-requirements-check

**Owner**: `eligibility-risk-analyst`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Maps target support paths to required documents and highlights what is still missing.

---

## When to Use Me

- A checklist of required documents is needed
- The client must be asked for missing evidence
- Submission readiness depends on document completeness

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/eligibility-risk-analyst/MEMORY.md

Loads during execution (lazy):
  .crux/docs/document-requirements-reference.md

Estimated token cost: ~400 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `target-program` | user / incentive-eligibility-check | Yes |
| `available-documents` | user | No |

---

## Steps

```
1. Read target program and available documents
2. Build required-document list
3. Mark available, missing, and unclear items
4. Write output to docs/advisory/risk/{client-or-date}-document-check.md
5. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/risk/{client-or-date}-document-check.md`
**Format**: `markdown`

```markdown
# Document Requirements Check

| Document | Status | Why Needed | Notes |
|---|---|---|---|
```

---

## Error Handling

| Condition | Action |
|---|---|
| Available docs not provided | mark status as unknown |
| Program path unclear | stop and ask for target path |
| Unexpected failure | Stop. Write error to bus. Notify user. |
