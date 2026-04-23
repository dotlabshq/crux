# Onboarding: Compliance Governance Lead

> This file defines the onboarding sequence for the `compliance-governance-lead` agent.
> Onboarding should gather the organisation context once so future ISO 27001,
> GDPR/KVKK/PCI-DSS, and procurement reviews can run with minimal repeated questioning.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/compliance-governance-lead/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the Compliance Governance Lead agent.

This agent will help you:
- prepare ISO 27001 documentation and certification-readiness material
- map GDPR, KVKK, and PCI-DSS obligations
- define procurement security requirements
- generate vendor / product security evaluation reports

I will ask a sequence of questions to capture your organisation profile,
regulatory scope, document expectations, and procurement review criteria.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. List existing compliance files under docs/compliance/ if the folder exists
  2. Check whether root docs/ exists and whether any policy/procedure files already exist
  3. Check whether .crux/docs/ contains generated compliance references
     If missing, note that they must be generated from this agent's assets during Step 4

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3
```

---

## Step 3 — User Questions

Ask one question at a time. Capture all answers in onboarding scratch notes and later persist to MEMORY.md.

```
Question order:

1. "What is the organisation name and primary business area?"
   default: unknown
   stores-to: docs/compliance/organisation-profile.md → Organisation

2. "Which frameworks are in scope right now?
    Options: ISO 27001, GDPR, KVKK, PCI-DSS"
   default: ISO 27001
   stores-to: docs/compliance/regulatory/applicability-matrix.md → In-Scope Frameworks

3. "What is the ISMS scope?
    Example: corporate IT + SaaS platform + support operations"
   default: organisation-wide
   stores-to: docs/compliance/iso27001/isms-scope.md → Scope

4. "Do you process personal data? If yes, what categories and in which countries?"
   default: yes — unspecified categories
   stores-to: docs/compliance/regulatory/privacy-scope.md → Personal Data Scope

5. "Do you store, process, or transmit cardholder data directly?"
   default: no
   stores-to: docs/compliance/regulatory/pci-dss-scope.md → Card Data Scope

6. "Do you already have policies, procedures, risk register, asset inventory, supplier inventory,
    incident records, access control matrix, or audit evidence repository?"
   default: none / partial
   stores-to: docs/compliance/organisation-profile.md → Existing Artefacts

7. "Where should compliance deliverables live?
    Default: docs/compliance/"
   default: docs/compliance/
   stores-to: MEMORY.md → deliverables-root

8. "When evaluating a new product, what is the primary use case?
    Example: HR SaaS, CRM, endpoint security, payment gateway, cloud hosting"
   default: general SaaS
   stores-to: docs/compliance/procurement/procurement-baseline.md → Typical Product Use Cases

9. "What approval outcome do you want procurement reviews to use?
    Default: approve / conditional approve / reject"
   default: approve / conditional approve / reject
   stores-to: MEMORY.md → procurement-decision-scale

10. "Which technical teams should be consulted when a product claim needs verification?
     Example: backend, Kubernetes, database, security"
    default: security + platform
    stores-to: MEMORY.md → technical-review-partners
```

---

## Step 4 — Generate Docs

Run the appropriate skills to produce the initial compliance artefacts.

```
Required docs for this agent:
  .crux/docs/iso27001-knowledge-base.md                       → generate from agents/compliance-governance-lead/assets/iso27001-knowledge-base.template.md if missing
  .crux/docs/privacy-and-pci-requirements.md                  → generate from agents/compliance-governance-lead/assets/privacy-and-pci-requirements.template.md if missing
  .crux/docs/vendor-security-baseline.md                      → generate from agents/compliance-governance-lead/assets/vendor-security-baseline.template.md if missing
  docs/compliance/organisation-profile.md                     → generate from onboarding answers
  docs/compliance/iso27001/isms-scope.md                      → skill: iso27001-isms-consulting
  docs/compliance/regulatory/applicability-matrix.md          → skill: regulatory-gap-assessment
  docs/compliance/procurement/procurement-baseline.md         → skill: vendor-security-evaluation
  docs/compliance/iso27001/document-plan.md                   → skill: policy-procedure-pack

If policies/procedures are missing and user wants a full pack:
  run policy-procedure-pack in bootstrap mode
```

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for Compliance Governance Lead:

  - organisation name and business area
  - frameworks in scope
  - ISMS scope
  - privacy / cardholder data scope
  - existing artefacts found
  - procurement review baseline
  - deliverable location

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/compliance-governance-lead/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → compliance-governance-lead / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: compliance-governance-lead
4. Notify user:
   "Compliance Governance Lead is ready.
    Use @compliance-governance-lead for ISO 27001, GDPR/KVKK/PCI-DSS, and procurement reviews."
```

---

## Re-Onboarding

Re-run onboarding when:
- the compliance scope changes materially
- new frameworks become in-scope
- deliverable location changes
- procurement review criteria change

Re-onboarding should update durable facts and preserve prior documents unless the user requests regeneration.
