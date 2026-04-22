---
name: iso27001-isms-consulting
description: >
  Builds or updates ISO 27001 ISMS guidance and document outputs for a specific
  organisation. Produces scope, context, risk methodology, Statement of Applicability,
  treatment roadmap, and audit-readiness guidance. Use when: the user requests ISO 27001
  certification consultancy, gap remediation planning, ISMS scoping, risk treatment,
  SoA preparation, or end-to-end certification-readiness support.
license: MIT
compatibility: opencode
metadata:
  owner: compliance-governance-lead
  type: read-write
  approval: No
---

# iso27001-isms-consulting

**Owner**: `compliance-governance-lead`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Creates ISO 27001 consultancy outputs that help an organisation move from undefined scope
to a documented, reviewable ISMS plan with clear artefacts and open gaps.

---

## When to Use Me

- ISO 27001 certification journey is starting
- Statement of Applicability, ISMS scope, or risk treatment plan is missing
- User asks for ISO 27001 readiness documents or audit guidance

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/compliance-governance-lead/MEMORY.md   (organisation profile, scope, frameworks)

Loads during execution (lazy):
  .crux/docs/iso27001-knowledge-base.md
  docs/compliance/organisation-profile.md
  docs/compliance/iso27001/

Estimated token cost: ~700 tokens plus any existing project-specific docs
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `organisation-name` | MEMORY.md | Yes |
| `isms-scope` | MEMORY.md / user | Yes |
| `existing-artefacts` | organisation-profile.md / user | No |
| `target-output` | user | No — default: full pack |

---

## Steps

```
1. Load organisation context and ISO knowledge base

2. Determine deliverable mode:
   full-pack       → generate all core ISO 27001 artefacts
   gap-assessment  → generate current gaps and remediation roadmap
   update-existing → refresh only requested documents

3. Write or update:
   docs/compliance/iso27001/isms-scope.md
   docs/compliance/iso27001/context-and-interested-parties.md
   docs/compliance/iso27001/risk-methodology.md
   docs/compliance/iso27001/statement-of-applicability.md
   docs/compliance/iso27001/risk-treatment-plan.md
   docs/compliance/iso27001/audit-readiness-checklist.md

4. For each document:
   state assumptions
   state owner / review cadence
   list evidence expectations

5. If mandatory inputs are missing:
   write assumptions explicitly and add open questions to docs/compliance/iso27001/open-items.md

6. Skill complete — unload
```

---

## Output

**Writes to**: `docs/compliance/iso27001/`
**Format**: `markdown`

```markdown
docs/compliance/iso27001/
  isms-scope.md
  context-and-interested-parties.md
  risk-methodology.md
  statement-of-applicability.md
  risk-treatment-plan.md
  audit-readiness-checklist.md
  open-items.md
```

---

## Error Handling

| Condition | Action |
|---|---|
| Scope unknown | Stop and ask for ISMS scope |
| Existing docs conflict with new answers | Mark conflict, do not overwrite silently |
| Evidence repository missing | Note as gap in audit-readiness-checklist.md |
| Unexpected failure | Stop. Write error to bus. Notify user. |
