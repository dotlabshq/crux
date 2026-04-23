# Crux Manifest

> Live system state. Lives in .crux/workspace/MANIFEST.md — not committed.
> Coordinator reads this on every boot.
> Updated by coordinator and agents during operation.

**Last Updated**: {{DATE}}
**Constitution Version**: 1.0.0
**Installation Status**: {{pending-setup | active}}

---

## Agents

| Role ID | Tier | Status | Docs | Last Session |
|---|---|---|---|---|
| `{{ROLE_ID_1}}` | {{TIER}} | pending-onboard | ✗ | — |
| `{{ROLE_ID_2}}` | {{TIER}} | pending-onboard | ✗ | — |

<!--
Status values:
  pending-onboard   → onboarding not completed, agent cannot run
  onboarded         → ready to run
  degraded          → running but missing optional docs
  disabled          → manually disabled by user

Docs column: ✓ all required generated .crux/docs/ files present, ✗ any missing and still not generated
Last Session: ULID of last session under .crux/workspace/{role}/sessions/
-->

---

## Skills

| Skill | Owner | Auto-Trigger | Last Run |
|---|---|---|---|
| `{{SKILL_1}}` | `{{OWNER_1}}` | {{TRIGGER_1}} | — |
| `{{SKILL_2}}` | `{{OWNER_2}}` | {{TRIGGER_2}} | — |

---

## Docs

| File | Summary | Tokens (est.) | Last Updated |
|---|---|---|---|
| `.crux/docs/{{DOC_1}}` | `.crux/summaries/{{DOC_1}}` | — | — |
| `.crux/docs/{{DOC_2}}` | missing | — | — |

<!--
Tokens (est.) helps agents respect context budget before loading.
If a doc is missing → generate it from the owning agent's assets or local templates first.
If summary is missing → agent loads full doc and triggers doc-summariser skill.
-->

---

## Pending Amendments

<!-- Agent writes here when requesting a CONSTITUTION.md change -->
<!-- Coordinator surfaces to user before proceeding -->

*(none)*

<!--
Example:
  - id: AMD-001
    requested-by: kubernetes-admin
    section: "V. Context Budget"
    current: "hard-limit: 8000 tokens"
    proposed: "hard-limit: 12000 tokens"
    reason: "kubernetes architecture docs consistently hitting limit"
    status: pending | approved | rejected
    ts: 2026-04-21
-->

---

## Open Sessions

<!--
Coordinator sessions: .crux/workspace/sessions/{ulid}/
Agent sessions:       .crux/workspace/{role}/sessions/{ulid}/
A session is "open" if summary.md is missing.
-->

| Role | Session ID | Started | Notes |
|---|---|---|---|
| — | — | — | — |
