---
name: clave-workflow-manager
description: >
  Working rules for a Crux company that keeps its tasks and approvals in
  clave through the clave MCP integration: who a session is in clave, how it
  names itself, which token it holds, how a repository is set up and extended
  (`clave init` once, `clave add` later), and the claim → plan → approval →
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
  {repo}/AGENTS.md                            the clave project key of the repository

External requirement:
  clave MCP integration, one entry per team, configured in the folder the
  session opens in.
  Entry name:              clave-<team>            e.g. clave-software
  Expected tool namespace: mcp__clave-<team>__*    e.g. mcp__clave-software__whoami
  Token:                   the person's own agent token for that team, given
                           as ${CLAVE_TOKEN_<AGENT>} (the agent's name in
                           upper case; it equals the team's) from the
                           git-ignored .env.clave file, loaded before the
                           session opens. Never a literal in config, never
                           the owner token.
  CLI:                     @dotlabshq/clave ≥ 0.2.2 (`npx @dotlabshq/clave`)

Session start calls:
  whoami                     → org, role (agent), actor
  session_start { project }  → brief, memory (rules first), open items, cursor

Estimated token cost: ~900 tokens
Unloaded after: never while the session works in the company
```

---

## Model

```text
org      = the Crux company                      one per company
└── person   owner | admin | member               the account layer; agents are not accounts
    └── agent  <name>@<person>, bound to a unit    e.g. software@basri
        └── token  per machine (label: laptop, ci)

unit     = Crux team      1:1   e.g. software ↔ software-development
project  = repository     1:1   named in the repository's AGENTS.md;
                                sub-projects for areas inside a repository
```

Identity rules:

1. Agent names may repeat across people; the identity is `<name>@<person>`.
   Writes show as `agent:software@basri`.
2. One identity per folder: the team's agent token. The owner or person
   token is never kept in an MCP config. Owner-only acts (units, projects,
   review, decide) happen in the clave panel or through `clave init` /
   `clave add`, which sign the person in through the browser and keep that
   token in memory only.
3. The MCP entry name is per team and machine-independent: `clave-<team>`.
4. The coordinator team is no exception: agent `coordinator@<person>` in
   the unit Management, MCP entry `clave-coordinator`. It holds an agent
   token like every team and reaches owner-only acts the same way.

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

There is no one-shot setup session. Setup is a command the person runs, once
per repository per machine, and small additions later.

| Command | Does | Who runs it |
|---|---|---|
| `npx @dotlabshq/clave init` | First setup of a repository on this machine: matches the project, creates the person's own agent for the team, issues a token, writes the MCP entry (`clave-<team>`, `${CLAVE_TOKEN_<AGENT>}`, secret in git-ignored `.env.clave`) and the AGENTS.md block. Already set up → stops: "already set up (project X, agent Y); use `clave add`" | the person who will work there |
| `clave add unit\|project\|agent` | Adds to an existing setup | unit, project: the coordinator, with the person token of an owner or admin, on the operator's approval. agent: the person themself |

Rules:

- **MCP entry first, then the session.** A running session never gains a
  server; when an entry is added, open a new session.
- The coordinator never attempts owner-only setup (units, projects, tokens)
  with an agent token. It asks the operator to run `clave init` / `clave add`
  or to do it in the panel.
- A repository's `AGENTS.md` names its clave project key; without it the
  session has no project and asks before guessing.

---

## Steps — the item loop

```
0. Boot (read-only)
   whoami → actor must be an agent of this team
   session_start { project } → read the brief; memory entries with
   kind rule and status active are binding, everything else is notes
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
| `mcp__clave-<team>__*` tools missing | Check, in order: the MCP config of this folder names `clave-<team>`; the startup log; `whoami`. Report which step failed. Never ask for or print a token; the fix is `clave init` by the person, in a **new** session |
| `whoami` shows a person or another team's agent | Stop; the folder holds the wrong identity. Report it, do not work under it |
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
Tasks:    clave — actor {name}@{person}, project {key}, {n} open, {n} asked | tools missing: {step}
```
