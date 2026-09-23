# The company model — teams, ownership, and requests between them

> Design note, 2026-09-23. Decided in conversation; to be implemented by the
> `crux` team. Supersedes nothing yet: today Crux knows projects and roles.
> This adds the layer above them.

## The problem this solves

Crux today is **project-scoped and role-scoped**: one repository, one `.crux/`,
agents that are job descriptions (`backend-developer`, `web-pentester`). An
operator who runs several products, each of several repositories, with an
accounting book, a security practice and a design system on the side, has no
place to say *who owns what* and no way for one working session to hand work to
another except through the operator's head.

The operator's mental model is a company: **teams** that own things and keep
their own session, and a **coordinator** that routes and never does domain
work. This note makes that a Crux primitive.

## Three layers

```
~/.crux/                          framework home — installed, updated, read-only
  agents/ skills/ templates/ …    overwritten by update.sh
  companies.toml                  registry — never overwritten
  local/                          operator-private, never overwritten

<company root>/                   a git repository, anywhere on disk
  AGENTS.md                       bootstrap: "this is a Crux company"
  .crux/
    COMPANY.md                    id, name, coordinator team
    CONSTITUTION.md  SOUL.md      company rules and default identity
    decisions/  docs/  summaries/ company knowledge, as today
    teams/<team>/TEAM.md          who owns what
    requests/<team>/*.md          the board
    workspace/                    live state, gitignored

<project>/                        a repository a team owns
  AGENTS.md                       project rules; may name its company
  .crux/                          optional project knowledge, as today
```

Company state lives in the company repository and **never** in framework home:
`update.sh` overwrites framework home, and a company that disappears on update
is not a company. Framework home gains two protected paths, `companies.toml`
and `local/`, that the installer and updater must not touch.

A company root is any directory; it need not contain its projects. Ownership is
declared by path in `TEAM.md`, not by nesting. Nesting is still the recommended
layout because it gives the `AGENTS.md` cascade for free: a session in
`dotlabs/baseworks-ts/projects/auth-service` loads the company's, the
workspace's and the service's `AGENTS.md` in that order — the same inheritance
`SOUL.md` describes for identity, applied to rules.

## The registry: `~/.crux/companies.toml`

```toml
[dotlabs]
root = "/Users/h/Workspaces/dotlabs"

[b9]
root = "/Users/h/Workspaces/b9"

[z9]
root = "/Users/h/Workspaces/z9"
```

One framework home serves every company on the machine. The registry exists so
that a project living outside its company root, or a tool with no cwd, can find
the company.

## `COMPANY.md`

```markdown
---
id: dotlabs
name: dotlabs
coordinator: coordinator
created: 2026-09-23
---
One sentence on what the company is.
```

## Teams: `.crux/teams/<team>/TEAM.md`

A **role** is a reusable job description in framework home. A **team** is a
concrete unit of the company that wears one or more roles and **owns** things.
A working session's identity is a team, not a role.

```markdown
---
id: auth                          # qualified id is <company>/<team>: dotlabs/auth
roles:
  - backend-developer             # primary: its AGENT.md and SOUL are loaded
skills:                           # added to the roles' skill tables
  - api-surface-analyser
owns:                             # paths relative to the company root, or absolute
  - baseworks-ts/projects/auth-service
  - baseworks-ts/packages/baseworks-auth
also:                             # may edit, does not own (shared surfaces)
  - baseworks-ts/README.md
---

# auth

What this team is for, in a paragraph. Soul overrides below inherit
.crux/SOUL.md exactly as an agent's Soul Override does.

## Soul override
tone: …
additional-rules:
  - …
```

Rules:

- A team **owns** a path exclusively. Two teams cannot own the same path; the
  installer and the coordinator refuse it.
- A team edits only what it owns or is listed under `also`. Anything else is a
  request to the owning team — never a one-line patch. That is the rule that
  lets sessions run in parallel: the only files two teams both write are
  request files, and each has one writer at a time.
- Reading is unrestricted. A consumer team reads the producer's public surface
  (`README.md`, `openapi.yaml`, a client package) freely.
- The **coordinator is a team** whose `owns` is the company root itself (the
  `.crux/` knowledge, `AGENTS.md`, the registry entry). It routes, keeps the
  board, aggregates approvals, and does no domain work — the existing
  coordinator write-scope rule, unchanged.
- The `crux` repository is owned by a `crux` team like any other. The
  coordinator uses Crux; it does not develop it.

## Requests: `.crux/requests/<team>/<YYYY-MM-DD>-<slug>.md`

The board is the filesystem transport of `bus/protocol.md`. The message schema
is the frontmatter; the payload is the body; the file is human-readable and
git-diffable, which JSONL was not. The schema is kept so a later transport
(Redis, NATS) carries the same message.

```markdown
---
id: 01J8…                          # ulid
from: dotlabs/console
to: dotlabs/auth
type: task                         # task | approval-request | event | error
status: open                       # open | accepted | done | declined
parent_id:                         # the request this answers, if any
context_refs:
  - baseworks-ts/apps/console/lib/realm-live.ts:120
opened: 2026-09-23
closed:
---

# <one line: what is needed>

## Why
What the requester is building and what it is blocked on.

## What
The surface as the requester would consume it. The owner may change the
shape; say what must hold.

## Done when
A sentence the owner can test against.

## Owner's notes
Commit id, version, or the reason for declining.
```

The handshake:

```
open ──► accepted ──► done ──► requester deletes the file
  │
  └────► declined ──► requester deletes, or reopens with an answer (parent_id)
```

- A request sits in the folder of the team it is addressed to. A team starts
  its session by listing its folder — that is its inbox.
- Only the **owner** changes `status`, `closed` and *Owner's notes*. Only the
  **requester** deletes the file. A `done` file still in a folder is a
  requester that has not picked it up yet.
- A request that needs two teams is two files.
- `approval-request` goes to `requests/coordinator/`; the coordinator surfaces
  it in `workspace/inbox.md`, the human decision surface, and answers with
  `status` and a note. This replaces nothing in the inbox model; it gives
  teams one way to reach it.
- Cross-company: `to: z9/platform` resolves through the registry to that
  company's board. Allowed by the naming; not needed on day one.
- Committed in the company repository. Session-to-session messages in a host
  (a desktop app that can ping another session) are a **notification**, never
  the message: the file is the message.

## Resolution: how a session learns who it is

```
1. Company
   walk up from cwd to the nearest .crux/COMPANY.md
   else: the project's .crux/company (an id) → companies.toml → root
   else: ask, listing the registry

2. Team
   the team whose `owns` (or `also`) contains cwd — automatic
   cwd == company root → the coordinator team
   ambiguous or none → ask

3. Boot
   read COMPANY.md, CONSTITUTION.md, SOUL.md
   read the team's TEAM.md, then each role's AGENT.md and SOUL.md
   read .crux/workspace/<team>/{MEMORY,TODO,NOTES}.md
   list .crux/requests/<team>/          ← the inbox
   report: company, team, inbox, git status of owned repositories, tests
```

A session in `dotlabs/baseworks-ts/projects/auth-service` boots as
`dotlabs/auth` without being told. A session opened at `dotlabs/` boots as the
coordinator. The operator's start prompt becomes optional.

Path resolution order in `crux-coordinator` changes accordingly: **company**,
then project `.crux`, then framework home. Project `.crux/` keeps holding
project knowledge; company `.crux/` holds teams, the board and company
decisions. Knowledge precedence gains one level at the top:
`company decisions → project decisions → constitution → …`.

## Routing gains one step

Before routing by role, the coordinator routes by **ownership**:

```
0. Which team owns the path or repository the request is about?
   → write a request to that team; never edit it from here.
1. @role, 2. domain fit, 3. workflow …   (unchanged, now within a team)
```

Workflows that span teams become a sequence of requests with `parent_id`
linking them; the coordinator owns the sequence, each team owns its step.

## Ending a piece of work — a team's checklist

1. Tests green in the owned repositories.
2. Committed **there**; the message explains the decision.
3. Requests completed are `done` with commit id and version.
4. Requests opened sit in the other team's folder, committed at the company.
5. If the team's public surface changed, consumers have a request; the team
   does not update them itself.

## What the installer does

```
crux install                       framework home, as today
crux company init <id> [--root .]  COMPANY.md, AGENTS.md, .crux/ skeleton,
                                   teams/coordinator, requests/coordinator,
                                   registry entry
crux team add <id> --role … --owns …
```

The first company is the reference user: `dotlabs`, with the teams the
operator actually keeps open — `coordinator`, `crux`, `auth`, `platform`,
`billing`, `ui`, `security`, `accounting`; `finance` and `qa` when the first
real piece of work arrives. Teams split when an inbox gets crowded, not before.

## Migration

`dotlabs/baseworks-ts/docs/SESSIONS.md` and `docs/requests/` (2026-09-23) are
the prototype of this model, written before it existed in Crux. When the
`crux-team` skill and the templates land, they move up to
`dotlabs/.crux/teams/` and `dotlabs/.crux/requests/`, and the workspace
`AGENTS.md` keeps only a pointer.

## Known gaps in Crux this touches

- `CLAUDE.md` in the Crux repository still describes the old layout
  (`.crux/COORDINATOR.md`, `.crux/agents/`); the README and the coordinator
  skill describe the framework-home layout. Fix alongside.
- `bus/` is a protocol document with no transport. This note gives it one.

## Work items for the `crux` team

1. `templates/COMPANY.template.md`, `TEAM.template.md`, `REQUEST.template.md`
2. `skills/crux-team/SKILL.md` — ownership, the board, the handshake, the
   session start and end protocol
3. `crux-coordinator`: company in path resolution; ownership as routing step 0;
   `requests/coordinator/` feeding `inbox.md`
4. `companies.toml` and `local/` protected in `install.*` and `update.*`;
   `company init` and `team add`
5. `AGENTS.template.md` variant for a company root
6. Update `CLAUDE.md`
