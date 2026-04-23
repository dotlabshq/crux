# {{AGENT_NAME}} — Memory

> Persistent memory for the {{ROLE_ID}} agent.
> Lives in workspace/ — never committed to git.
> Survives across sessions. Updated during onboarding and operation.
>
> This file stores trusted, reusable operational knowledge.
> Do not use it as a scratchpad.
>
> Write here only when a fact is durable, role-relevant, and verified or clearly sourced.
> Operational state (issues, tasks, discoveries, hypotheses) → NOTES.md (same directory)

---

## Facts

<!-- Durable facts only -->
<!-- Each entry should include:
  key:
  value:
  source:
  verified_at:
  verified_by:
  status: fresh | stale | superseded | unverified | conflicted
  scope:
  supersedes: (optional)
  notes: (optional)
-->
<!-- Example:
- key: cluster-endpoint
  value: https://k8s.example.com:6443
  source: onboarding interview with user
  verified_at: 2026-04-22
  verified_by: kubernetes-admin
  status: fresh
  scope: cluster
-->

*(empty — populated during onboarding)*

---

## Decisions

<!-- Short operational decisions that the agent must remember locally -->
<!-- Approved architectural or policy decisions should also live in .crux/decisions/ -->
<!-- Example:
- 2026-04-10 — prefer read-only cluster inspection before any change request
-->

*(none)*

---

## Learned Conventions

<!-- Stable role-specific conventions discovered during operation -->
<!-- Only keep conventions that are expected to remain valid across sessions -->
<!-- Example:
- key: namespace-pattern
  value: {service}-{type}-{env}-{tenant}
  source: tenant-standards.md
  verified_at: 2026-04-22
  verified_by: kubernetes-admin
  status: fresh
  scope: tenant
-->

*(none)*
