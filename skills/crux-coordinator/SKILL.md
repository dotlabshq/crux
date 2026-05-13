---
name: crux-coordinator
description: >
  Operating protocol for a Crux project. Use when: an agent or IDE needs to
  understand Crux layout, locate framework-home definitions, locate project
  `.crux` state, route work to the right agent, run onboarding, manage task
  continuity, or decide which files are read-only versus writable.
license: MIT
compatibility: all
metadata:
  owner: coordinator
  type: read-write
  approval: "Yes before destructive project changes"
---

# crux-coordinator

**Owner**: `coordinator`
**Type**: `read-write`
**Approval**: `Yes before destructive project changes`

---

## What I Do

Defines the Crux project-operation protocol in a tool-neutral form. Any LLM,
IDE, or future runtime can read this skill and understand how to use global
framework definitions with a project-local `.crux` workspace.

Crux has no required runtime in this version. The markdown protocol is the
runtime contract.

---

## Path Model

There are two active roots:

```text
{framework-home}/     reusable Crux framework, read mostly
{project}/.crux/      project knowledge and live state
```

Default framework home:

```text
$HOME/.crux
```

Framework home contains:

```text
{framework-home}/agents/
{framework-home}/skills/
{framework-home}/templates/
{framework-home}/workflows/
{framework-home}/bus/
{framework-home}/docs/
```

Project `.crux` contains:

```text
.crux/CONSTITUTION.md
.crux/SOUL.md
.crux/docs/
.crux/summaries/
.crux/decisions/
.crux/workflows/        project-specific generated workflows, if any
.crux/bus/              project-local bus/events, when enabled
.crux/workspace/
```

Rules:

- Treat `{framework-home}` as read-only during normal project work.
- Write project knowledge to `.crux/docs/`, `.crux/summaries/`, and `.crux/decisions/`.
- Write live state to `.crux/workspace/`.
- Do not copy global agent or skill definitions into project knowledge.
- Do not write learned project facts into `{framework-home}`.

---

## Project Knowledge Model

Crux project knowledge follows the LLM Wiki idea without requiring a separate
`.crux/knowledge/` directory.

Compiled project knowledge lives in:

```text
.crux/docs/
.crux/summaries/
.crux/decisions/
```

Live state lives in:

```text
.crux/workspace/
```

Use `.crux/docs/` for generated operational references, `.crux/summaries/` for
token-efficient versions, and `.crux/decisions/` for approved project decisions
that multiple agents must respect.

---

## Boot Sequence

Run these checks before meaningful Crux work:

```text
1. Locate project root.
2. Locate project `.crux/`.
   If missing, run workspace initialisation.
3. Locate framework home.
   Default: $HOME/.crux.
   If missing, ask user to install or point to a framework home.
4. Read project core if present:
   .crux/CONSTITUTION.md
   .crux/SOUL.md
   .crux/workspace/MANIFEST.md
   .crux/workspace/TODO.md
   .crux/workspace/inbox.md
   .crux/workspace/MEMORY.md
5. Surface pending items:
   pending onboarding, pending approvals, open tasks, open sessions.
```

---

## Agent Start Protocol

When the user invokes an agent role:

```text
1. Read {framework-home}/agents/{role-id}/AGENT.md.
2. Read {framework-home}/agents/{role-id}/SOUL.md if present.
3. Check .crux/workspace/MANIFEST.md for role status.
4. If pending-onboard, run {framework-home}/agents/{role-id}/onboarding.md.
5. Load project state:
   .crux/workspace/{role-id}/MEMORY.md
   .crux/workspace/{role-id}/TODO.md
   .crux/workspace/{role-id}/NOTES.md
6. Reuse a matching open TODO before creating a new one.
7. Load role skills from {framework-home}/skills/{skill-name}/SKILL.md only when triggered.
```

If `.crux/docs/{topic}.md` is missing and the agent expects it, generate it from
the owning agent's framework-home assets before continuing:

```text
{framework-home}/agents/{role-id}/assets/
```

---

## Write Scope

Coordinator-like operation may write only orchestration state:

```text
.crux/workspace/MANIFEST.md
.crux/workspace/TODO.md
.crux/workspace/inbox.md
.crux/workspace/MEMORY.md
.crux/workspace/sessions/**
.crux/workspace/{role-id}/TODO.md
.crux/bus/**
```

It must not write domain state on behalf of agents:

```text
.crux/workspace/{role-id}/MEMORY.md
.crux/workspace/{role-id}/NOTES.md
.crux/workspace/{role-id}/output/**
.crux/docs/**
.crux/summaries/**
.crux/decisions/**
application code or domain-owned project files
```

If work requires a forbidden write, hand off to the owning agent.

---

## Workflow Protocol

For workflow requests:

```text
1. Prefer .crux/workflows/{workflow}.md when a project-specific workflow exists.
2. Otherwise read {framework-home}/workflows/{workflow}.md.
3. If neither exists, search framework-home agent assets for:
   {framework-home}/agents/*/assets/{workflow}.workflow.template.md
4. Collect workflow inputs before steps run.
5. For each step:
   - check owning agent onboarding status
   - create or resume linked TODO records
   - route to the owning agent
   - treat completion as TODO status = done
6. Record step status in .crux/workspace/sessions/{id}/scratch.md.
```

---

## Skill Protocol

Skills are markdown-first and runtime-ready.

Rules:

- A skill must be usable by an LLM that only reads `SKILL.md`.
- A future runtime may parse metadata, inputs, approval gates, steps, and output
  paths, but the skill must not require that runtime.
- Project writes go to project `.crux` or domain-owned project files, never to
  framework home.
- Approval gates in the skill always override automation.

---

## Output

This skill does not produce a domain artifact by itself. It gives the operating
protocol for routing, onboarding, task continuity, and project `.crux` state
management.
