---
id: {{DECISION_ID}}
title: {{DECISION_TITLE}}
status: {{proposed | accepted | superseded | deprecated}}
date: {{DATE}}
agent: {{ROLE_ID | human}}
supersedes: {{DECISION_ID | —}}
tags: [{{TAG_1}}, {{TAG_2}}]
---

# {{DECISION_TITLE}}

## Context

{{What is the situation? What constraints or forces are at play?
Be specific — future readers should understand why this decision was necessary.}}

## Decision

{{What was decided, stated clearly and without ambiguity.}}

## Consequences

**Good:**
- {{positive consequence or benefit}}

**Trade-offs / Accepted Risks:**
- {{negative consequence or known limitation}}

## Compliance Notes

{{SOC Type 2, security, or regulatory implications. Omit section if not applicable.}}

---

<!--
HOW TO USE THIS TEMPLATE

id:          Short slug — e.g. k8s-multi-tenant-namespace-model
             Format: {domain}-{topic}-{aspect}
status:      proposed   → drafted, not yet approved
             accepted   → in effect
             superseded → replaced by another decision (link in supersedes)
             deprecated → no longer relevant
agent:       Who proposed this — a role-id or "human"
supersedes:  ID of the decision this replaces, or — if none
tags:        e.g. [kubernetes, networking, soc2, storage, tenancy]

FILE LOCATION: .crux/decisions/{id}.md
After writing, add a row to MANIFEST.md → Decisions table.
-->
