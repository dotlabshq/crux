---
pending-clarification: false
stale-operations-view: false
---

# {{AGENT_NAME}} — Notes

> Operational state for the {{ROLE_ID}} agent.
> Lives in workspace/ — never committed to git.
> Updated freely during operation.
>
> Frontmatter flags are read by auto-triggers at session start.
> Set pending-clarification: true when unresolved triage questions remain.
> Set stale-operations-view: true when team or operations notes need a refresh.
> Reset flags to false once the issue is resolved.
>
> Use this file for temporary work state, not durable truth.
> Stable facts and sourced conventions → MEMORY.md (same directory)
> Approved architectural or policy choices → .crux/decisions/
> Canonical task state → TODO.md (same directory)

---

## Known Issues

<!-- Active problems to surface at session start -->
<!-- Example:
- issue: longhorn replica degraded on node-02
  detected_at: 2026-04-10
  status: active
  next_check: inspect replica health after node reboot
-->

*(none)*

---

## Pending Tasks

<!-- Supporting context only. Canonical task state belongs in TODO.md. -->
<!-- Example:
- task: namespace audit
  scope: prod-app done, prod-db remaining
  status: in-progress
  owner: kubernetes-admin
-->

*(none)*

---

## Discoveries

<!-- Temporary context, workarounds, observations, and unverified findings -->
<!-- Promote only verified reusable facts into MEMORY.md -->
<!-- Example:
- note: kubectl get events is slow
  observed_at: 2026-04-22
  status: unverified
  follow_up: test with --field-selector=type=Warning
-->

*(none)*

---

## Follow-ups

<!-- Things to ask, verify, or hand off in a future session -->
<!-- Move approval or operator decisions to workspace/inbox.md once that file exists -->

*(none)*
