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

## When to Use Me

- Starting work in a Crux-enabled project
- Resolving whether a path belongs to framework home or project `.crux`
- Routing a request to the correct agent
- Running or resuming agent onboarding
- Creating or updating coordinator task state
- Generating missing project `.crux/docs/` from framework-home agent assets
- Deciding whether a write belongs to coordinator control-plane state or to a
  domain agent
- Preparing future runtime-compatible execution from markdown-only skills

Do not use this skill to perform domain work directly. Use it to route,
initialise, resume, and govern the work.

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

## Path Resolution

Resolve paths in this order:

```text
1. Project root
   The current working directory or nearest parent containing `.crux/`.

2. Project `.crux`
   {project}/.crux/

3. Framework home
   a. CRUX_HOME, if configured
   b. $HOME/.crux
   c. explicit user-provided path

4. Framework source fallback
   Only when developing Crux itself: repository root containing agents/,
   skills/, templates/, and COORDINATOR.md.
```

Use placeholders consistently:

```text
{framework-home}/agents/{role}/AGENT.md
{framework-home}/skills/{skill}/SKILL.md
.crux/workspace/{role}/MEMORY.md
.crux/docs/{topic}.md
```

If a file is missing:

```text
framework definition missing  → ask user to install/update Crux or choose another role/skill
project workspace missing     → run workspace initialisation
project compiled doc missing  → generate from framework-home assets if the owning agent declares it
project live state missing    → create from framework-home template when allowed by this protocol
```

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

Knowledge precedence:

```text
1. .crux/decisions/             approved project decisions
2. .crux/CONSTITUTION.md        project rules
3. .crux/docs/                  generated project references
4. .crux/summaries/             compact views of docs
5. .crux/workspace/*/MEMORY.md  live role memory
6. .crux/workspace/*/NOTES.md   temporary supporting notes
7. session scratch/context      ephemeral work notes
```

If sources conflict, prefer the highest-precedence source and surface the
conflict instead of silently merging it.

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

Boot output should be short:

```text
Crux ready.
Project: {project-name or unknown}
Framework: {framework-home}
Pending: {pending-items or none}
```

---

## Workspace Initialisation

Run this when project `.crux/` or `.crux/workspace/MANIFEST.md` is missing.

```text
1. Ask project identity:
   - project name
   - one-sentence purpose

2. Ask initial agents:
   - role ids from {framework-home}/agents/
   - allow empty selection if user only wants the base workspace

3. Ask critical operations:
   - destructive actions requiring manual approval
   - production or sensitive environments

4. Create project compiled-knowledge directories:
   .crux/docs/
   .crux/summaries/
   .crux/decisions/

5. Create project workspace:
   .crux/workspace/
   .crux/workspace/sessions/
   .crux/workspace/MANIFEST.md from {framework-home}/templates/MANIFEST.template.md
   .crux/workspace/TODO.md from {framework-home}/templates/TODO.template.md
   .crux/workspace/inbox.md from {framework-home}/templates/INBOX.template.md
   .crux/workspace/MEMORY.md from {framework-home}/templates/MEMORY.template.md

6. Create project rules:
   .crux/CONSTITUTION.md from {framework-home}/templates/CONSTITUTION.template.md
   .crux/SOUL.md from {framework-home}/templates/SOUL.template.md

7. For each initial agent:
   .crux/workspace/{role}/
   .crux/workspace/{role}/TODO.md from TODO.template.md
   .crux/workspace/{role}/sessions/
   MANIFEST agent status = pending-onboard
```

Do not create `.crux/agents/`, `.crux/skills/`, or `.crux/templates/` in the
project. Those belong to framework home.

---

## Routing Protocol

Route by explicit mention first, then by domain fit.

```text
1. If user writes @{role-id}:
   route to that role if {framework-home}/agents/{role-id}/AGENT.md exists.

2. If no role is mentioned:
   inspect agent frontmatter descriptions and skill triggers.
   choose the narrowest agent that owns the work.

3. If request spans multiple agents:
   check {framework-home}/workflows/ and .crux/workflows/.
   if no workflow fits, route the first concrete step and record follow-up tasks.

4. If request is only about Crux structure, onboarding, task state, or routing:
   handle it with this coordinator protocol.

5. If request is domain execution:
   hand off to the owning agent.
```

Routing decision table:

| Request shape | Action |
|---|---|
| `@role` mentioned | Load that role, unless missing or disabled |
| one clear domain | Route to owning agent |
| multiple ordered domains | Use or create workflow plan |
| missing project `.crux` | Run workspace initialisation |
| missing agent docs | Generate docs from framework-home assets through owning agent |
| unclear owner | Ask one concise clarification question |
| destructive operation | Require explicit approval before execution |

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

Agent stop protocol:

```text
1. Ensure any active TODO is done, waiting, blocked, or canceled.
2. Ask the agent to persist durable facts to its MEMORY.md.
3. Ask the agent to write session summary.md.
4. Update MANIFEST task/session summary.
```

Coordinator may update task bookkeeping for a role, but the role owns its
domain memory, notes, output, and project docs.

---

## Task State Protocol

Before meaningful work:

```text
1. Read .crux/workspace/TODO.md for coordinator tasks.
2. Read .crux/workspace/{role}/TODO.md for role tasks when routing to a role.
3. If a matching open task exists, resume it.
4. Otherwise create a new task record before execution.
```

Task statuses:

```text
todo        known but not started
in_progress actively being worked
waiting     paused for external input or approval
blocked     cannot proceed until blocker is resolved
done        acceptance criteria met
canceled    superseded or intentionally stopped
```

Task update rules:

- Set `in_progress` before material execution.
- Set `waiting` when asking for user approval, external input, or another agent.
- Set `blocked` only when there is no available next step.
- Set `done` only when acceptance criteria are met.
- Add evidence references to session scratch, output, docs, decisions, or command
  results where useful.

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

## Project Docs And Decisions

Use compiled project knowledge deliberately.

```text
.crux/docs/       generated references, runbooks, architecture notes, inventories
.crux/summaries/  compact versions of docs for context budgeting
.crux/decisions/  approved cross-agent standards and durable project decisions
```

Rules:

- Generate `.crux/docs/` only from the owning agent's framework-home assets,
  local discovery, or an approved domain skill.
- Generate `.crux/summaries/` after docs are created or materially changed.
- Write `.crux/decisions/` only through approval flow or onboarding rules.
- If a decision conflicts with a doc, the decision wins and the doc should be
  updated or marked stale.
- Do not store transient notes in docs, summaries, or decisions.

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

Workflow state rules:

- Coordinator owns workflow sequencing and step state.
- Each domain agent owns its step output.
- Required step failure stops the workflow unless the workflow says otherwise.
- Optional step failure is recorded and surfaced, not hidden.
- Rollback must follow the workflow file; never invent destructive rollback
  without approval.

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

## Approval Gates

Always ask before:

- deleting files, namespaces, databases, accounts, or project state
- overwriting existing `.crux/docs/`, `.crux/decisions/`, or workspace memory
- changing `.crux/CONSTITUTION.md`
- applying broad automated fixes
- installing tools or using network/cloud services
- writing to framework home during project work

Approval prompt must include:

```text
1. target paths or systems
2. exact action
3. expected impact
4. rollback or recovery note, if relevant
```

Ambiguous approval is not approval.

---

## Failure Handling

| Condition | Action |
|---|---|
| framework home missing | Ask user to install Crux or provide framework home |
| project `.crux` missing | Run workspace initialisation |
| agent missing | List available agents from framework home |
| skill missing | Report missing skill and owning agent, then ask whether to continue without it |
| MANIFEST unreadable | Stop and ask before repair |
| TODO conflict | Prefer existing open task; ask if duplicate intent is unclear |
| doc/decision conflict | Surface conflict and prefer decision until resolved |
| approval denied | Mark task waiting or canceled with reason |

---

## Output

This skill does not produce a domain artifact by itself. It gives the operating
protocol for routing, onboarding, task continuity, and project `.crux` state
management.

When used interactively, return:

```text
- selected agent or workflow
- files read
- state updates needed
- pending approvals or blockers
- immediate next action
```
