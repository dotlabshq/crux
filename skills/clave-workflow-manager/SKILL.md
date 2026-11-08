---
name: clave-workflow-manager
description: >
  Working rules for a Crux company that keeps its tasks and approvals in
  clave through the clave MCP integration: who a session is in clave, how it
  names itself (`session_start { project, as: team }`), how a machine and a
  repository are set up (`clave init` once,
  `clave add` later), and the claim → plan → approval →
  work → evidence → finish loop every item follows. Use when: the company's
  COMPANY.md says `task_tool: clave-workflow-manager`, a session starts in
  such a company, an item is pulled or finished, a Class A step needs
  approval, a repository or team must be connected to clave, or the clave
  MCP tools are missing.
license: MIT
compatibility: all
metadata:
  owner: company-coordinator
  type: read-write
  approval: "No for steps on your own items; Yes for Class A (request_approval) and for setup"
  category: task-tool
  tool: clave
---

# clave-workflow-manager

**Owner**: `company-coordinator`
**Type**: `read-write`
**Approval**: `No for steps on your own items; Yes for Class A (request_approval) and for setup`
**Category**: `task-tool`

---

## What I Do

Makes clave the task and approval layer of a Crux company. The Crux side
(teams, ownership, the request board) stays as `crux-team` describes; this
skill says how a team session records its work in clave, which identity it
uses, and how a new repository or team gets connected. It is loaded only
when the company chose it at onboarding (`COMPANY.md` → `task_tool`).

Product reference: `https://clave.one/getting-started-ai.md`.

---

## When to Use Me

- A coordinator or team session boots in a company whose `task_tool` is this skill
- An item is claimed, planned, worked, finished or handed off
- A step is Class A (prod, external publishing, deletes) or uncertain (Class B)
- A repository, unit or agent must be connected to clave (`clave init` / `clave add`)
- The clave MCP tools are not in the session

---

## Context Requirements

```
Requires already loaded:
  {company-root}/.crux/COMPANY.md             task_tool: clave-workflow-manager
  {company-root}/.crux/teams/{team}/TEAM.md   the team this session is
  {repo}/AGENTS.md                            clave project key and `Work as: <team>`

External requirement:
  clave MCP integration: one entry per machine, user scope, named `clave`,
  holding the person's personal token. The person adds it once, outside any
  session (`clave init` prints the command); a session never adds it and
  never sees the token.
  Expected tool namespace: mcp__clave__*          e.g. mcp__clave__whoami
  Server:                  clave with #131 (session_start takes `as`)
  CLI:                     @dotlabshq/clave ≥ 0.3.0 (`npx @dotlabshq/clave`)

Session start calls:
  session_start { project: "<key>", as: "<team>" }
                             → from here on the session acts as the agent
                               <team>@<handle> with the agent role; returns
                               brief, memory (rules first), open items, cursor
  whoami                     → confirms org, role (agent) and actor

Estimated token cost: ~900 tokens
Unloaded after: never while the session works in the company
```

---

## Model

```text
org      = the Crux company                      one per company
└── person   owner | admin | member               the account layer; holds the personal token
    └── agent  <team>@<handle>, bound to a unit    e.g. software@basri
                                                   registered on first `as`

unit     = Crux team      1:1   e.g. software ↔ software-development,
                                coordinator ↔ Management
project  = repository     1:1   named in the repository's AGENTS.md;
                                sub-projects for areas inside a repository
```

Identity rules:

1. One MCP entry per machine (`clave`, user scope) with the person's
   personal token. The team is chosen per session, not per folder:
   `session_start { project, as: "<team>" }`. The repository's `AGENTS.md`
   says which team (`Work as: <team>`).
2. After `session_start` the session is the agent `<team>@<handle>` with the
   agent role; writes show as `agent:software@basri`. Agent names repeat
   across people; the identity is `<team>@<handle>`.
3. First use of a team registers the person's agent for it. An owner's or
   admin's is active at once; a member's waits for one approval by an owner
   or admin — until then tools answer `approval_required`. Report it and
   stop; do not retry under another team.
4. The coordinator team is no exception: `as: "coordinator"`, unit
   Management.
5. The session never handles the token: it does not read, print, ask for or
   write it. Owner-only acts (units, projects, review, decide) are the
   person's, in the panel or through `clave add`, never through the agent
   session.
6. Agent tokens, `.env.clave` and `clave-<agent>` MCP entries exist only for
   unattended agents (CI, loops). A person's interactive session does not
   use them.

---

## Session Names

```text
<team>:<project>@<person>                 software:crux@basri   finance:funding@basri
<team>:<project> · <topic>@<person>       software:clave · driptab@basri   (side sessions)
```

`via` on every clave step is the session name. A side session inherits the
parent's prefix and adds its topic.

---

## Setup Grows Over Time

There is no one-shot setup session. A person sets up a machine once and a
repository once; additions come later.

| Command | Does | Who runs it |
|---|---|---|
| `claude mcp add --scope user --transport http clave https://clave.one/v1/mcp --header "Authorization: Bearer <personal token>"` | The machine's one clave entry. `clave init` prints it with the token filled in | the person, once per machine, outside a session |
| `npx @dotlabshq/clave init` | Writes the repository's `AGENTS.md` block (project key, `Work as: <team>`) and prints the user-scope command above if the machine lacks it | the person, once per repository |
| `clave add unit\|project` | Adds a unit or project to the org | an owner or admin, on the operator's approval; the coordinator may prepare it, not run it with an agent session |
| `clave add agent` | An **unattended** agent (CI, loop): agent token, `.env.clave`, `clave-<agent>` entry | the person who runs that automation |

Rules:

- **MCP entry first, then the session.** A running session never gains a
  server; after the entry is added, open a new session.
- The coordinator never attempts owner-only setup through its agent
  session. It tells the operator what to run (`clave add …`) or to use the
  panel.
- A repository's `AGENTS.md` names its clave project key and team; without
  them the session asks before guessing.

---

## Steps — the item loop

```
0. Boot (read-only)
   session_start { project, as: "<team>" } → read the brief; memory
   entries with kind rule and status active are binding, everything else
   is notes
   whoami → actor must be <team>@<handle>, role agent
   Report: open items, questions asked to you, active freezes

1. Pull
   list_items { project, claimable: true } or the item the operator named
   claim_item { id, via }

2. Plan
   report_progress { id, pct, note: the plan, via }
   Summarise the plan to the operator and wait for approval before editing

3. Approval gates while working
   Class A (prod, external publishing, deletes) → request_approval, wait
   Confidence < 0.7 (Class B)                   → request_approval, wait
   A question                                   → ask { to } (targets from
                                                  get_project_settings)
   While waiting the lease is frozen; the decision shows in get_item's
   journal and the item's allowed list.

4. Work
   Edit only inside the team's owned paths (crux-team § Ownership).
   report_progress renews the lease; a lapsed lease on your own item is
   taken back silently by the next step.

5. Evidence
   add_evidence { id, kind: commit|pr|url|test|session, ref, note, via }
   Tests, commits and PRs are evidence; discussion goes to comment_item.

6. Finish
   finish_item { id, via } — review is the operator's, never the agent's

7. Before leaving
   remember { project, kind, text, refs } what the next session needs
   my_updates { since: cursor } to catch up on what changed meanwhile
```

Push, release, installing or updating framework home, and anything the
Crux constitution reserves for the operator stay the operator's, or need an
explicit yes in the same turn.

---

## Approval Gate

```
Before a Class A or Class B step:

1. request_approval on the item: target, exact action, expected impact,
   rollback note.
2. Say in the session what was requested and stop that line of work.
3. On approve: do the step, add_evidence.
4. On reject: stop, record the no-change outcome in the journal.

A project freeze refuses Class A requests; whoami lists freezes.
```

---

## Error Handling

| Condition | Action |
|---|---|
| `mcp__clave__*` tools missing | Check, in order: a user-scope `clave` entry exists (`claude mcp list`, names only); the startup log. Report which step failed. Never ask for or print a token; the fix is the person's one-time `claude mcp add --scope user …` (printed by `clave init`), then a **new** session |
| An agent tool answers `session_required` | The connection was renewed (deploy, 30 min idle). Call `session_start { project, as }` again, then retry the step once |
| `approval_required` after `session_start` | The person's agent for this team waits for an owner's or admin's approval. Report it and stop; do not switch to another team |
| `whoami` shows a person, or another team's agent | Stop; `as` was wrong or missing. Call `session_start` with the team from `AGENTS.md`; do not work under the wrong identity |
| No clave project key in `AGENTS.md` | Ask the operator for the key or for `clave init`; do not guess from the path |
| Item held by someone else | Do not take it; ask or pick another claimable item |
| Project frozen | Class A refused; report the freeze and wait |
| Memory `rule` conflicts with the Crux constitution | Constitution wins; report the conflict to the coordinator |
| Unexpected MCP failure | Stop. Report the call and the error. Do not retry writes blindly |

---

## Output

**Writes to**: clave (items, progress, evidence, memory) and, through the
Crux protocol, the team's owned paths.
**Format**: structured calls; no files of its own.

A boot line for the crux-team report:

```text
Tasks:    clave — actor {team}@{handle}, project {key}, {n} open, {n} asked | tools missing: {step} | approval_required
```
