---
name: vendor-security-evaluation
description: >
  Evaluates a product or vendor against business need, security baseline, and
  compliance obligations, then writes a procurement security evaluation report.
  Use when: the user asks whether a product is suitable to buy, needs a supplier
  security review, wants a KVKK/GDPR/PCI-DSS-aware procurement checklist, or
  requests a recommendation with approve / conditional approve / reject outcome.
license: MIT
compatibility: opencode
metadata:
  owner: compliance-governance-lead
  type: read-write
  approval: No
---

# vendor-security-evaluation

**Owner**: `compliance-governance-lead`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns a product purchase request into a structured security and compliance evaluation.
The report explains business fit, security requirements, regulatory impact, mandatory controls,
missing evidence, risks, and a recommendation.

---

## When to Use Me

- Product purchase or supplier review request arrives
- User asks whether a SaaS, platform, tool, or service is compliant enough to use
- Procurement wants a structured security evaluation report before approval

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/compliance-governance-lead/MEMORY.md

Loads during execution (lazy):
  .crux/docs/vendor-security-baseline.md      (generate from agent assets first if missing)
  .crux/docs/privacy-and-pci-requirements.md  (generate from agent assets first if missing)
  docs/compliance/organisation-profile.md
  docs/compliance/procurement/

Estimated token cost: ~700 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `product-name` | user | Yes |
| `business-need` | user | Yes |
| `deployment-model` | user | Yes — SaaS / self-hosted / managed service / on-prem |
| `data-types` | user | Yes |
| `vendor-claims` | user / documents | No |
| `required-frameworks` | MEMORY.md / user | No |

---

## Steps

```
1. Capture product context:
   product name, use case, users, deployment model, integration points, data types

2. Determine obligation profile:
   privacy impact
   card-data impact
   audit / logging impact
   supplier access impact

3. Evaluate the product against mandatory controls:
   authentication and SSO / MFA
   role-based access control and least privilege
   encryption in transit and at rest
   audit logging and exportability
   backup / resilience / availability commitments
   data residency and transfer posture
   deletion / retention controls
   incident notification and breach handling
   subprocessor transparency
   contract and DPA support

4. Write:
   docs/compliance/procurement/{slug}-evaluation-report.md

5. Recommendation must be one of:
   approve
   conditional-approve
   reject

6. If evidence is missing:
   state missing evidence explicitly and downgrade recommendation accordingly

7. Skill complete — unload
```

---

## Output

**Writes to**: `docs/compliance/procurement/{product-slug}-evaluation-report.md`
**Format**: `markdown`

```markdown
# Product Security Evaluation Report

## 1. Request Summary
- Product
- Business need
- Requesting team
- Deployment model

## 2. Data and Regulatory Impact
- Personal data impact
- KVKK / GDPR implications
- PCI-DSS implications
- Criticality rating

## 3. Mandatory Security Requirements
- IAM / SSO / MFA
- RBAC
- Encryption
- Logging
- Backup / resilience
- Data residency
- Deletion / retention
- Incident notification
- Supplier transparency

## 4. Assessment Results
| Control | Status | Evidence | Notes |

## 5. Risks and Gaps
| Risk | Severity | Required action |

## 6. Required Conditions Before Approval
- contract / DPA
- SSO enablement
- log export
- residency commitment
- security testing evidence

## 7. Recommendation
- approve | conditional-approve | reject
- rationale

## 8. Suggested Security Features
- list of features the product should have if not currently present
```

---

## Error Handling

| Condition | Action |
|---|---|
| Business need unclear | Stop and ask user to clarify intended use |
| Data type unknown | Mark report as incomplete and list blocker |
| Vendor evidence missing | Mark control status as evidence-missing |
| Unexpected failure | Stop. Write error to bus. Notify user. |
