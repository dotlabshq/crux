---
name: regulatory-gap-assessment
description: >
  Evaluates an organisation against GDPR, KVKK, PCI-DSS, or a combined regulatory scope
  and produces a control gap matrix with remediation priorities. Use when: the user requests
  a GDPR/KVKK/PCI-DSS assessment, wants a compliance roadmap, needs a cross-framework mapping,
  or asks which controls are missing for a target regulatory profile.
license: MIT
compatibility: opencode
metadata:
  owner: compliance-governance-lead
  type: read-write
  approval: No
---

# regulatory-gap-assessment

**Owner**: `compliance-governance-lead`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces an applicability matrix and a gap report that maps each relevant framework requirement
to implemented controls, missing controls, evidence expectations, and remediation priority.

---

## When to Use Me

- User asks: "Are we aligned with GDPR / KVKK / PCI-DSS?"
- A compliance roadmap is needed before audit or procurement
- A product or process introduces new privacy or card-data obligations

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/compliance-governance-lead/MEMORY.md

Loads during execution (lazy):
  .crux/docs/privacy-and-pci-requirements.md (generate from agent assets first if missing)
  docs/compliance/organisation-profile.md
  docs/compliance/regulatory/

Estimated token cost: ~650 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `frameworks` | MEMORY.md / user | Yes |
| `data-scope` | MEMORY.md / organisation-profile.md | Yes |
| `cardholder-data-present` | MEMORY.md | No |
| `assessment-target` | user | No — organisation-wide by default |

---

## Steps

```
1. Determine applicable frameworks and organisational data scope

2. Build control mapping across:
   GDPR
   KVKK
   PCI-DSS
   existing ISO 27001 controls if available

3. Write or update:
   docs/compliance/regulatory/applicability-matrix.md
   docs/compliance/regulatory/gap-assessment.md
   docs/compliance/regulatory/remediation-roadmap.md

4. For each requirement:
   mark implemented / partial / missing / not applicable
   state evidence expected
   state remediation owner suggestion

5. Highlight blockers:
   unlawful transfer risk
   missing retention / deletion controls
   missing processor / supplier controls
   missing logging / access / card-data protection controls

6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/compliance/regulatory/`
**Format**: `markdown`

```markdown
applicability-matrix.md
gap-assessment.md
remediation-roadmap.md
privacy-scope.md
pci-dss-scope.md
```

---

## Error Handling

| Condition | Action |
|---|---|
| Framework list missing | Ask user to confirm in-scope regulations |
| Data scope unclear | Mark blockers in gap report and stop at assumptions |
| Product touches payment data but PCI scope unknown | Flag as high-risk unknown |
| Unexpected failure | Stop. Write error to bus. Notify user. |
