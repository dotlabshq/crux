---
name: policy-procedure-pack
description: >
  Generates or updates a baseline governance document pack for compliance work,
  including policies, procedures, registers, and review matrices aligned to ISO 27001
  and common privacy / payment expectations. Use when: the user needs policy and
  procedure templates, governance documentation from scratch, or wants to bootstrap
  an audit-ready document pack.
license: MIT
compatibility: opencode
metadata:
  owner: compliance-governance-lead
  type: read-write
  approval: No
---

# policy-procedure-pack

**Owner**: `compliance-governance-lead`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Creates a practical document pack for governance and audit-readiness with a clear
owner, purpose, scope, review cadence, and linkage to evidence expectations.

---

## When to Use Me

- Policies and procedures are missing or inconsistent
- User asks for ISO 27001 document preparation support
- A baseline governance pack is needed for audit or certification readiness

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/compliance-governance-lead/MEMORY.md

Loads during execution (lazy):
  .crux/docs/iso27001-knowledge-base.md
  .crux/docs/privacy-and-pci-requirements.md
  docs/compliance/organisation-profile.md

Estimated token cost: ~600 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `applicable-frameworks` | MEMORY.md | Yes |
| `organisation-name` | MEMORY.md | Yes |
| `existing-documents` | user / docs | No |
| `pack-mode` | user | No — bootstrap (default) or selective |

---

## Steps

```
1. Read organisation profile and applicable frameworks

2. Build document plan:
   policies
   procedures
   registers
   review calendar

3. Write or update:
   docs/compliance/iso27001/document-plan.md
   docs/compliance/iso27001/policies/information-security-policy.md
   docs/compliance/iso27001/policies/access-control-policy.md
   docs/compliance/iso27001/policies/asset-management-policy.md
   docs/compliance/iso27001/procedures/incident-management-procedure.md
   docs/compliance/iso27001/procedures/access-review-procedure.md
   docs/compliance/iso27001/registers/required-registers.md

4. If GDPR or KVKK is in scope:
   write privacy-governance additions under docs/compliance/regulatory/

5. If PCI-DSS is in scope:
   add card-data handling and access review obligations to the document plan

6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/compliance/`
**Format**: `markdown`

```markdown
docs/compliance/iso27001/document-plan.md
docs/compliance/iso27001/policies/*.md
docs/compliance/iso27001/procedures/*.md
docs/compliance/iso27001/registers/required-registers.md
docs/compliance/regulatory/privacy-governance-plan.md
docs/compliance/regulatory/pci-governance-plan.md
```

---

## Error Handling

| Condition | Action |
|---|---|
| Deliverable root missing | Create docs/compliance/ structure first |
| Framework scope ambiguous | Ask user or mark assumption explicitly |
| Existing document title conflicts | Update document plan and avoid silent overwrite |
| Unexpected failure | Stop. Write error to bus. Notify user. |
