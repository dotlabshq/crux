# Crux — Agent Guidance

## What Is Crux

Crux is a markdown-native, multi-agent workspace framework.
Every rule, identity, protocol, and domain document lives in a plain `.md` file
under `.crux/`. No runtime required to read or understand what the system is doing.

**Three layers:**
```
.crux/              static      who we are        committed, versioned
.crux/workspace/    dynamic     what we know      gitignored, live state
.crux/workspace/    ephemeral   what we did       gitignored, session logs
  sessions/ and
  {role}/sessions/
```

---

## Project Status

Active development. Core architecture is stable.

### Completed

**Scripts:**
- `scripts/install.sh` — curl entry point: downloads `.crux/` skeleton from GitHub, installs agents/skills, runs convert
- `scripts/convert.sh` — syncs `.crux/agents/` and `.crux/skills/` → tool-specific locations (opencode, claude-code, cursor)

**Core files (always committed):**
- `COORDINATOR.md` — boot sequence, agent lifecycle, @mention routing, amendment handling
- `SOUL.md` — generated at install, root identity and tone
- `CONSTITUTION.md` — generated at install, universal rules + amendment process
- `AGENTS.md` — this file (lives in `.crux/`, not project root)

**Templates:**
- `CONSTITUTION.template.md` — universal rules skeleton
- `SOUL.template.md` — root identity, CSS cascade inheritance model
- `MANIFEST.template.md` — live system state, lives in workspace/
- `INBOX.template.md` — human approvals, operator handoffs, and pending decisions
- `MEMORY.template.md` — agent persistent memory, lives in workspace/{role}/
- `NOTES.template.md` — operational state, lives in workspace/{role}/
- `AGENT.template.md` — opencode + openclaw frontmatter, context budget, triggers
- `SKILL.template.md` — opencode folder-based SKILL.md format
- `WORKFLOW.template.md` — multi-agent workflow: inputs, steps, state, rollback
- `DECISION.template.md` — ADR-lite: context, decision, consequences, compliance notes
- `decisions/TENANT-NAMING-CONVENTIONS.template.md` — generated at installation if multi-tenant; produces `decisions/tenant-naming-conventions.md`
- `onboarding.template.md` — 7-step: intro → discovery → questions → docs → SOC2 gaps → confirm → finalise

**Agents:**
- `agents/kubernetes-admin/` — AGENT.md + onboarding.md (SOC Type 2 checks, multi-tenant setup)
- `agents/postgresql-admin/` — AGENT.md + onboarding.md (SOC Type 2 checks, schema/role governance, tenant provisioning)
- `agents/backend-developer/` — AGENT.md only (onboarding.md not yet written)

**Skills:**
- `skills/kubernetes-architecture-analyser/` — live cluster scan → docs/kubernetes.md
- `skills/kubernetes-tenant-onboarding/` — Kubernetes step of tenant onboarding: namespace, quota, NetworkPolicy, RBAC, Grafana, updates docs/tenants.md
- `skills/postgresql-schema-analyser/` — live DB scan → docs/postgresql.md *(not yet written)*
- `skills/postgresql-tenant-provisioning/` — PostgreSQL step of tenant onboarding: schema/database, role, grants, updates docs/db-tenants.md
- `skills/postgresql-table-audit/` — tenant-aware table naming audit: snake_case, required columns, PKs, RLS, index naming → docs/db-table-audit.md
- `skills/codebase-scanner/` — directory scan → docs/backend.md
- `skills/doc-summariser/` — docs/ → summaries/, updates MANIFEST.md

**Workflows:**
- `workflows/tenant-onboarding.md` — coordinator orchestrates: Kubernetes → PostgreSQL → finance (future) → xxxapp (future)

**Bus:**
- `bus/protocol.md` — transport-agnostic message schema (filesystem → Redis → NATS)

### Not Yet Written
- `CONSTITUTION.md` — real file (generated at install from template)
- `SOUL.md` — real file (generated at install from template)
- `workspace/MANIFEST.md` — real file (generated at install from template)
- `agents/backend-developer/onboarding.md` — not yet written
- `skills/postgresql-schema-analyser/SKILL.md` — not yet written
- Additional agents: `finance-agent`, `xxxapp-agent`, `security-agent`, `devops-lead`
- Additional workflow steps: `finance-tenant-onboarding`, `xxxapp-tenant-onboarding`

---

## Full Directory Structure

```
.crux/
├── CONSTITUTION.md          generated at install — universal rules
├── SOUL.md                  generated at install — root identity
├── COORDINATOR.md           always present — boot + routing logic
├── AGENTS.md                always present — this file (project status + conventions)
│
├── templates/
│   ├── CONSTITUTION.template.md
│   ├── SOUL.template.md
│   ├── MANIFEST.template.md
│   ├── INBOX.template.md
│   ├── MEMORY.template.md
│   ├── NOTES.template.md
│   ├── AGENT.template.md
│   ├── SKILL.template.md
│   ├── WORKFLOW.template.md
│   ├── DECISION.template.md
│   ├── onboarding.template.md
│   ├── decisions/               generated decisions — coordinator fills from Q&A
│   │   └── TENANT-NAMING-CONVENTIONS.template.md
│   └── skills/
│       └── example-skill/
│           └── SKILL.md
│
├── agents/
│   └── {role-id}/
│       ├── AGENT.md         opencode+openclaw frontmatter + context budget + triggers
│       ├── SOUL.md          optional — tone override
│       └── onboarding.md    6-step onboarding sequence
│
├── skills/
│   └── {skill-name}/
│       └── SKILL.md         opencode skill format (name must match folder)
│
├── decisions/               architectural decisions (ADR-lite) — committed, versioned
│   └── {id}.md              format: {domain}-{topic}.md, e.g. k8s-multi-tenant.md
│
├── workflows/               multi-agent workflows orchestrated by coordinator
│   └── {name}.md            each step delegates to one agent + one skill
│
├── docs/                    lazy-loaded domain knowledge — generated by skills
│   └── {topic}.md
│
├── summaries/               token-efficient summaries — generated by doc-summariser
│   └── {topic}.md
│
├── bus/
│   ├── protocol.md
│   ├── broadcast.jsonl
│   └── {role-id}/
│       └── to-{target}.jsonl
│
└── workspace/               gitignored — all live state
    ├── MANIFEST.md          system index — agent status, docs, amendments
    ├── inbox.md             human approvals, handoffs, and pending operator decisions
    ├── MEMORY.md            coordinator memory
    ├── current              symlink → sessions/{ulid}/
    ├── sessions/            coordinator sessions
    │   └── {ulid}/
    │       ├── scratch.md
    │       ├── context-cache.md
    │       └── summary.md
    └── {role-id}/
        ├── MEMORY.md        agent persistent memory — facts, decisions, conventions
        ├── NOTES.md         operational state — issues, pending tasks, discoveries
        ├── output/          generated files, persistent
        ├── current          symlink → sessions/{ulid}/
        └── sessions/
            └── {ulid}/
                ├── scratch.md
                ├── context-cache.md
                └── summary.md
```

---

## Key Design Decisions

**Memory lives in workspace/, not agents/**
`agents/{role}/` is identity — versioned, committed.
`workspace/{role}/MEMORY.md` is knowledge — live, gitignored.
This means agent definitions never change during operation.

**Decisions live in decisions/, not docs/**
`docs/` is generated, ephemeral knowledge (can be regenerated from a live cluster).
`decisions/` is deliberate, human-approved choices — committed, versioned.
Agents propose decisions; users approve them. Approved decisions are never auto-deleted.
MANIFEST.md tracks all decisions in a Decisions table (ID, status, date).
Template: `templates/DECISION.template.md`

**decisions/ is the home for cross-agent standards**
Naming conventions, isolation models, and platform-wide policies that multiple agents
must enforce go in `decisions/`, not in any single agent's `docs/`.
`docs/` files are layer-specific operational references *derived from* decisions.
When they conflict, `decisions/` wins (source-of-truth priority #1).
Example: `decisions/tenant-naming-conventions.md` governs namespace, schema,
role, and table naming across Kubernetes, PostgreSQL, and future agents.

**Some decisions are generated, not hand-written**
Same pattern as `CONSTITUTION.md`: a template under `templates/decisions/` holds the
structure and placeholders; the coordinator generates the real file during installation
from Q&A answers. The generated file is committed and versioned like any other decision.
`templates/decisions/TENANT-NAMING-CONVENTIONS.template.md` → generated at install
if multi-tenant → `decisions/tenant-naming-conventions.md`.

**Workflows orchestrate across agents — skills execute within one agent**
A skill is always owned by one agent and runs in that agent's context.
A workflow spans multiple agents — the coordinator collects inputs once,
then delegates each step to the owning agent via @mention.
Workflows live in `workflows/`. Template: `templates/WORKFLOW.template.md`
MANIFEST.md tracks active workflows and step status.

**MANIFEST.md is dynamic**
Lives in `workspace/MANIFEST.md`, not `.crux/`. It changes every session.
Gitignored — no noise in git history.

**inbox.md is the human decision surface**
Lives in `workspace/inbox.md`, not in agent notes.
Approvals, operator handoffs, blocked questions, and unresolved human checkpoints
should be visible there rather than buried inside session-local state.

**CONSTITUTION.md is static and formal**
Committed, versioned. Agents cannot modify it directly.
Amendment process: agent → MANIFEST.md pending → user approves → version increments.

**SOUL inheritance — CSS cascade**
```
CONSTITUTION.md          cannot be overridden
.crux/SOUL.md            root defaults
agents/{role}/SOUL.md    agent overrides tone/language only
```

**Context loading order**
```
1. CONSTITUTION.md              always (~1000 tokens)
2. SOUL.md                      always (~500 tokens)
3. agents/{role}/AGENT.md       always (~800 tokens)
4. workspace/{role}/MEMORY.md   always (~400 tokens)
──────────────────────────────────────────────────
Base cost: ~2700 tokens / Hard limit: 8000 tokens

5. workspace/{role}/NOTES.md    session start
6. summaries/{doc}.md           on demand
7. docs/{doc}.md                on demand
8. skills/{name}/SKILL.md       on trigger, unloaded after
```

**doc-summariser keeps context lean**
Every docs/ file gets a summaries/ counterpart (max 200 tokens).
Agents load the summary first — only load full doc when detail is needed.
MANIFEST.md tracks token estimates so agents can budget before loading.

**Bus is transport-agnostic**
Message schema never changes. Transport evolves:
filesystem JSONL → in-memory → Redis Streams → NATS JetStream.

**Sessions are per-role**
`workspace/{role}/sessions/{ulid}/` — each agent's history is isolated.
Coordinator has its own `workspace/sessions/` at root level.
`current` symlink per role — each agent knows its active session independently.

---

## Read This Before Continuing Work

If you are an AI agent picking up this project, read in this order:

1. This file — status and decisions
2. `.crux/COORDINATOR.md` — how the system boots, routes, and runs workflows
3. `.crux/templates/CONSTITUTION.template.md` — rule structure
4. `.crux/templates/AGENT.template.md` — agent format
5. `.crux/templates/SKILL.template.md` — skill format
6. `.crux/templates/WORKFLOW.template.md` — workflow format
7. `.crux/workspace/MANIFEST.md` — current system state (if it exists)

Do not write new files before reading these seven.

---

## Conventions for New Agents

```
1. Copy templates/AGENT.template.md → agents/{role}/AGENT.md
2. Fill frontmatter: name, description, mode, model, temperature,
   tools, permission, color (#rrggbb), emoji, vibe
3. Define Identity — expertise, responsibilities, out-of-scope boundaries
4. Define Job Definition — mission, owns, success metrics, required inputs,
   allowed outputs, boundaries, escalation rules
5. Define context budget — list lazy docs explicitly
6. Define skills table — reference skills/{name}/
7. Define auto-triggers
8. Copy templates/onboarding.template.md → agents/{role}/onboarding.md
9. Fill onboarding: discovery checks + user questions + required docs
10. Update workspace/MANIFEST.md — add agent row, status: pending-onboard
```

## Conventions for New Skills

```
1. Create folder: skills/{skill-name}/
2. Create skills/{skill-name}/SKILL.md
3. name in frontmatter must match folder name exactly
4. description must include "Use when:" scenarios (agents decide from this)
5. Set metadata: owner, type (read-only | read-write), approval
6. If approval required: define approval gate section
7. Reference skill in owning agent's AGENT.md skills table
8. If skill is a step in a workflow: add "Workflow:" field to header, update workflow file
9. After first run: doc-summariser should generate a summary if docs/ produced
```

## Conventions for New Workflows

```
1. Copy templates/WORKFLOW.template.md → workflows/{workflow-name}.md
2. Fill frontmatter: name, description, trigger
3. Define inputs — collected by coordinator before any steps run
4. Define steps in order — each step references one agent + one skill
   Mark parallel steps explicitly with [PARALLEL]
5. Set required: yes | no and on-fail: stop | warn-and-continue | skip per step
6. Define rollback behaviour for any destructive steps
7. Add a Workflows row to workspace/MANIFEST.md
   Format: workflow name | step summary (✓ active, — future) | version | last run
8. In each owning skill's SKILL.md: add "Workflow:" field referencing this file
```

---

## Knowledge Lifecycle Rules

Knowledge must remain useful and trustworthy over time.
Crux separates identity, working state, reusable facts, generated knowledge, and approved decisions.

### 1. Knowledge Classes

- `decisions/` — approved, normative knowledge; what the system has chosen and why
- `docs/` — generated or maintained domain knowledge; inventory, analysis, runbooks, architecture notes
- `workspace/{role}/MEMORY.md` — durable operational facts the agent should retain across sessions
- `workspace/{role}/NOTES.md` — temporary operational state; open questions, pending tasks, current risks
- `workspace/inbox.md` — human decisions, approvals, or handoffs that must not be silently buried in notes

### 2. Source-of-Truth Priority

When sources disagree, use this priority order:

1. `decisions/`
2. live inspection / direct verification
3. `docs/`
4. `MEMORY.md`
5. `NOTES.md`

Rules:
- `NOTES.md` is never a final source of truth
- `MEMORY.md` stores reusable facts, not unverified hypotheses
- `docs/` may be detailed but can become stale
- `decisions/` governs architecture, policy, and approved operating choices

### 3. Memory vs Notes

Write to `MEMORY.md` only if the information is:
- likely to be reused in future sessions
- specific to the agent's role or domain
- verified directly, derived from a trusted source, or linked to a clear source
- stable enough to outlive the current task

Keep information in `NOTES.md` if it is:
- a pending task
- an open question
- a temporary hypothesis
- a short-lived workaround
- a session-scoped risk, discovery, or follow-up

At session end, notes should be:
- promoted to `MEMORY.md` if they became verified reusable facts
- moved into `docs/` if they became broader domain knowledge or a runbook
- moved into `decisions/` if they became approved policy or architecture
- removed or archived if they are no longer active

### 4. Freshness States

Durable knowledge should use one of these states:
- `fresh` — recently verified and safe to rely on
- `stale` — may still be true, but needs re-verification
- `superseded` — replaced by newer information
- `unverified` — recorded for awareness but not yet trusted as fact
- `conflicted` — disagrees with another source and must be resolved

### 5. Minimum Metadata

Persistent fact records in `MEMORY.md` should include at least:
- `key`
- `value`
- `source`
- `verified_at`
- `verified_by`
- `status`
- `scope`

Optional fields:
- `supersedes`
- `notes`

Example:

```md
- key: production-namespaces
  value: [prod-app, prod-db, prod-ingress]
  source: kubectl get ns (2026-04-22)
  verified_at: 2026-04-22
  verified_by: kubernetes-admin
  status: fresh
  scope: cluster
```

### 6. Conflict Resolution

When knowledge conflicts:
- `decisions/` beats all lower-priority sources for policy and architecture
- live inspection beats `docs/`, `MEMORY.md`, and `NOTES.md` for current system state
- the newer verified source beats the older verified source when both are below decisions
- `NOTES.md` never overrides a verified durable source; it should instead record the conflict

Agents must not silently overwrite conflicts.
They should mark affected entries as `conflicted` or `superseded` and explain why.

### 7. Freshness Expectations

Different knowledge classes age at different rates.
Suggested defaults:
- live infrastructure facts: verify often, short freshness window
- tenant inventory and operational topology: medium freshness window
- repository structure and architecture summaries: longer freshness window
- approved decisions: no freshness expiry, but may be superseded explicitly

Each agent may define stricter freshness expectations in its own docs or onboarding.

### 8. Agent Update Discipline

Agents should update knowledge in this order:
1. read summary first if one exists
2. load full doc only if needed
3. verify live when the task is operationally sensitive
4. update `NOTES.md` during exploration
5. promote only verified reusable facts into `MEMORY.md`
6. write `decisions/` only through explicit approval flow

Principle:
`MEMORY.md` is not a scratchpad; it is a compact store of trusted operational facts.

---

## Future Phase Recommendations

These are product-direction notes for later phases.
They are intentionally not part of the current required architecture yet.

### 1. Agent Job Definition

Each agent should eventually have an explicit job definition section in `agents/{role}/AGENT.md`
or a dedicated `JOB.md` loaded with the agent.

Minimum fields:
- mission — what this agent owns
- responsibilities — what it is expected to do without ambiguity
- success metrics — what good output looks like
- inputs — what information must exist before work starts
- outputs — which docs/files/decisions it is allowed to produce
- boundaries — what it must not decide or change alone
- escalation rules — when it must stop and ask a human

Goal:
Make every agent measurable as an operational role, not just a prompt identity.

### 2. Security and Permission Model

Future versions should move beyond simple allow/ask rules and define a clearer capability model.

Candidate additions:
- capability-based permissions per agent, skill, and workflow step
- risk classes for actions: low, medium, high, critical
- approval policies by action type, not only by file/tool
- secret access boundaries and credential scope rules
- immutable audit log for sensitive actions and approvals
- policy hooks for destructive or production-scoped operations

Goal:
Make agent permissions explainable, reviewable, and safe under real operational use.

### 3. Evaluation System

Add an evaluation layer in a later phase.

Candidate additions:
- replayable task runs
- golden scenarios per agent and workflow
- regression checks after template/skill changes
- success, latency, cost, and human-override metrics
- safety and hallucination review cases for risky domains

Goal:
Measure whether agents are improving or regressing over time.

### 4. Failure Handling

Failure handling should be designed deliberately in a later phase.
Part of this may belong in the upper execution engine rather than the markdown architecture itself.

Candidate additions:
- retry and backoff policy
- timeout handling and stuck-agent detection
- partial completion and resume points
- rollback definitions for multi-step workflows
- degraded-mode behaviour when docs, tools, or agents are unavailable

Goal:
Treat failure as a first-class system path, not an exception.

### 5. Human Collaboration Protocol

Human approval and operator handoff should become explicit system primitives.

Candidate additions:
- `.crux/workspace/inbox.md` for approvals, handoffs, and pending operator decisions
- standard approval request format
- decision checkpoints inside workflows
- override logging with human reason notes
- end-of-run handoff summaries for operators

Goal:
Make human-in-the-loop collaboration visible, durable, and auditable.

### 6. Observability

Add observability in a later phase once execution patterns are stable.

Candidate additions:
- per-session timeline
- context loading trace
- tool/action trace
- token and cost accounting
- workflow step duration and failure reports

Goal:
Explain what the system did, why it did it, and what it cost.

### 7. Knowledge Lifecycle

Memory and notes are separated well, but knowledge freshness still needs a lifecycle model.
This should be prioritised before the system accumulates stale operational facts.

Goal:
Prevent silent knowledge drift as the workspace grows.

### 8. Agent Composition

The current model is role-first.
A later phase should evaluate when task-first composition is a better fit.

Candidate additions:
- planner / executor / reviewer / auditor split for complex tasks
- temporary specialist agents for bounded runs
- workflow-level review gates between execution phases
- agent composition rules for parallel vs sequential delegation

Goal:
Support both durable domain roles and temporary task-oriented coordination patterns.
