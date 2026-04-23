# Agents Index

This file is the human-readable index of all currently defined agents under `.crux/agents/`.

It answers four questions:
- what each agent does
- which skills it uses
- whether it is currently `primary` or `subagent`
- whether it should stay user-facing or be treated as effectively private

---

## Exposure Model

Crux currently uses `mode: primary` and `mode: subagent`.

For product and UX decisions, this index also uses a practical exposure label:

- `Public Primary`
  User-facing entry point. Direct interaction is expected and useful.

- `Routed Subagent`
  Specialist that should normally be invoked by a coordinator, lead, or another primary agent.

- `Private Specialist`
  Crux does not currently have a separate `private` mode.
  In practice this means:
  - keep the agent as `subagent`
  - hide it from normal user-facing entry points
  - call it only from a lead agent, workflow, or coordinator

Rule of thumb:
- broad ownership + frequent direct use → `primary`
- narrow specialist work + high-risk operations → `subagent`
- narrow specialist work + end users should not choose it directly → `subagent`, but treat it as `Private Specialist`

---

## Current Recommendations

### Public Primary

These are good direct entry points for most users:
- `backend-developer`
- `frontend-developer`
- `platform-engineer`
- `compliance-governance-lead`
- `personal-productivity-coach`
- `team-operations-coach`
- `red-team-lead`

### Routed Subagent

These are strong specialist agents, but direct entry should usually be limited to technical operators:
- `kubernetes-admin`
- `postgresql-admin`

### Private Specialist

These should usually stay hidden behind the lead/orchestration layer:
- `web-pentester`
- `api-pentester`
- `mobile-pentester`
- `network-pentester`

Reason:
- they are narrow specialists
- they depend on engagement context
- they should not be selected casually without scope and authorization controls

---

## Agent Catalogue

| Role ID | Current Mode | Recommended Exposure | What It Does | Core Skills |
|---|---|---|---|---|
| `backend-developer` | `primary` | `Public Primary` | Server-side implementation, API review, backend tests, schema-sensitive review, backend docs | `api-surface-analyser`, `service-implementation`, `backend-test-writer`, `schema-change-review`, `backend-doc-writer`, `codebase-scanner`, `test-coverage-check`, `dependency-audit` |
| `frontend-developer` | `primary` | `Public Primary` | UI implementation, component structure, state-flow review, frontend tests, frontend docs | `ui-structure-analyser`, `component-implementation`, `frontend-test-writer`, `state-flow-review`, `frontend-doc-writer` |
| `platform-engineer` | `primary` | `Public Primary` | Environments, CI/CD, deployment review, observability, runtime summaries | `environment-setup-review`, `ci-pipeline-implementation`, `deployment-config-review`, `observability-check`, `runtime-incident-summary` |
| `kubernetes-admin` | `subagent` | `Routed Subagent` | Kubernetes cluster operations, namespace governance, workload triage, storage and network policy work | `kubernetes-architecture-analyser`, `kubernetes-tenant-onboarding`, `kubernetes-namespace-audit`, `kubernetes-network-policy-apply`, `kubernetes-storage-health`, `workload-triage` |
| `postgresql-admin` | `subagent` | `Routed Subagent` | PostgreSQL schema, roles, backups, replication, tenant provisioning, query review | `postgresql-schema-analyser`, `postgresql-tenant-provisioning`, `postgresql-table-audit`, `postgresql-backup-verify`, `postgresql-query-analyser` |
| `compliance-governance-lead` | `primary` | `Public Primary` | ISO 27001, GDPR, KVKK, PCI-DSS, policy/procedure work, procurement security evaluations | `iso27001-isms-consulting`, `policy-procedure-pack`, `regulatory-gap-assessment`, `vendor-security-evaluation` |
| `personal-productivity-coach` | `primary` | `Public Primary` | Personal task triage, daily planning, weekly review notes, markdown note structure | `task-capture-normaliser`, `task-triage`, `today-plan-writer`, `weekly-review-writer`, `follow-up-questioner` |
| `team-operations-coach` | `primary` | `Public Primary` | Team structure, weekly team plans, weekly reviews, blocker tracking, leadership summaries under `operations/` | `team-roster-manager`, `weekly-team-planner`, `weekly-team-review`, `cross-team-summary-writer`, `blocker-dependency-tracker`, `leadership-style-mapper` |
| `red-team-lead` | `primary` | `Public Primary` | Pentest engagement entry point, scope and authorization checks, specialist coordination, final findings and reporting | `engagement-setup`, `passive-recon`, `finding-document`, `report-generator` |
| `web-pentester` | `subagent` | `Private Specialist` | Web application testing for OWASP Web Top 10 style issues | `web-recon`, `web-exploit` |
| `api-pentester` | `subagent` | `Private Specialist` | REST/GraphQL API security testing, auth and authorization abuse, JWT/OAuth review | `api-recon`, `api-exploit` |
| `mobile-pentester` | `subagent` | `Private Specialist` | APK/IPA static and dynamic analysis, Frida/hooking, storage and transport review | `mobile-static-analysis`, `mobile-dynamic-analysis` |
| `network-pentester` | `subagent` | `Private Specialist` | Network scanning, service fingerprinting, SSL/TLS review, CVE mapping, infrastructure exposure checks | `network-scan`, `network-exploit` |

---

## Design Notes

### Why `backend-developer`, `frontend-developer`, and `platform-engineer` stay primary

These are broad ownership agents:
- they are frequently useful as direct entry points
- they benefit from onboarding and long-lived memory
- they sit at stable layer boundaries

### Why `kubernetes-admin` and `postgresql-admin` stay subagents

These are deep operational specialists:
- risky commands
- environment-specific knowledge
- narrower domain scope

They can be exposed to advanced operators, but default routing through coordinator or another primary is safer.

### Why pentest specialists should usually be private

These agents should generally not be user-facing because:
- they depend on engagement scope and authorization
- they are easy to misuse outside a controlled workflow
- `red-team-lead` is the right public entry point

So the practical recommendation is:
- keep them as `subagent`
- hide them from casual direct use
- invoke them through `red-team-lead` or pentest workflows

---

## Planned But Not Yet Added

These are part of the current direction but are not yet defined under `.crux/agents/`:
- `mobile-developer`
- `data-engineer`
- `finance-agent`
- `security-agent`
- `xxxapp-agent`

When they are added, update this index first.
