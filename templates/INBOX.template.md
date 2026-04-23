# Crux Inbox

> Human decision surface for this Crux workspace.
> Lives in `.crux/workspace/inbox.md` — never committed to git.
> Use this file for approvals, blocked questions, operator handoffs, and pending checkpoints.
>
> Do not bury human-required decisions in `NOTES.md`.

---

## Pending Approvals

<!-- Use for actions waiting on explicit user approval -->
<!-- Example:
- id: APR-001
  requested_by: kubernetes-admin
  type: approval
  status: pending
  requested_at: 2026-04-22
  summary: Apply NetworkPolicy to prod namespace
  impact: Limits cross-namespace traffic for prod-app
  needs_from_human: approve | reject | request changes
-->

*(none)*

---

## Blocked Questions

<!-- Use for questions that prevent progress -->
<!-- Example:
- id: Q-001
  requested_by: backend-developer
  type: question
  status: pending
  requested_at: 2026-04-22
  summary: Confirm API versioning strategy
  context: Existing routes mix /v1 and unversioned endpoints
  needs_from_human: choose target versioning rule
-->

*(none)*

---

## Operator Handoffs

<!-- Use when an agent stops with a concise handoff for a human operator -->
<!-- Example:
- id: H-001
  requested_by: kubernetes-admin
  type: handoff
  status: pending
  requested_at: 2026-04-22
  summary: Manual certificate rotation required
  context: Cluster access is read-only from this environment
  needs_from_human: rotate cert and report completion
-->

*(none)*

---

## Resolved

<!-- Move completed, rejected, or superseded inbox items here with final status -->

*(none)*
