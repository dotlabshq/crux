---
name: crux-team
description: >
  Operating protocol for a team inside a Crux company: who a session is, what
  it owns, how it asks other teams for work through the request board, and how
  it starts and ends a piece of work. Use when: a session starts inside a Crux
  company, a change touches a path another team owns, a request must be
  opened, accepted, completed, declined or picked up, or a team needs to know
  its inbox, its owned repositories, or its end-of-work checklist.
license: MIT
compatibility: all
metadata:
  owner: coordinator
  type: read-write
  approval: "No for own requests and owned paths; Yes for anything else"
---

# crux-team

**Owner**: `coordinator`
**Type**: `read-write`
**Approval**: `No for own requests and owned paths; Yes for anything else`

---

## What I Do

Makes a working session a **team** of a **company**: a concrete unit that
wears one or more roles, owns paths exclusively, and reaches other teams only
through request files on the company board.

`crux-coordinator` remains the protocol for project `.crux/` state, roles,
onboarding and routing. This skill adds the layer above it. Where both apply,
company rules are resolved first.

---

## When to Use Me

- A session starts anywhere under a directory with `.crux/COMPANY.md`, or in a
  project whose `.crux/company` names a registered company
- A change would touch a path the current team does not own
- Opening, accepting, completing, declining or deleting a request
- Ending a piece of work and checking it is handed off correctly
- Creating a company with the operator (Company Onboarding)

---

## Model

```text
role     reusable job description        {framework-home}/agents/{role}/AGENT.md
team     unit of a company; owns paths   {company-root}/.crux/teams/{team}/TEAM.md
company  a git repository of teams       {company-root}/.crux/COMPANY.md
```

A session's identity is a team, never a bare role. Its qualified id is
`{company}/{team}`, e.g. `dotlabs/auth`.

Company layout — the company repository holds no code; the repositories
its teams own may live beside it, anywhere on disk, each with its own git:

```text
{workspace}/
  company/          the company repository (git) — {company-root}
  nixscale/         a code repository (git), owned via `owns: ../nixscale`
  muhasebe/
```

Nesting code repositories under the company root also works and gives the
`AGENTS.md` cascade, but then the company repository must ignore them.

Inside the company root:

```text
{company-root}/
  AGENTS.md                     bootstrap: this is a Crux company
  .crux/
    COMPANY.md                  id, name, coordinator team
    CONSTITUTION.md  SOUL.md    company rules and default identity
    decisions/ docs/ summaries/ company knowledge
    teams/{team}/TEAM.md        who owns what
    requests/{team}/*.md        the board — one folder per team, its inbox
    workspace/                  live state, gitignored
      {team}/MEMORY.md TODO.md NOTES.md
```

Machine registry, in framework home, never overwritten by `update.sh`:

```text
{framework-home}/companies.toml     [{company-id}] root = "/abs/path"
{framework-home}/local/             operator-private files
```

Company state never lives in framework home.

---

## Resolution — who am I

Run at session start, before reading anything else in the company.

```text
1. Company
   a. walk up from cwd to the nearest directory containing .crux/COMPANY.md
   b. else the nearest `.crux/company` file walking up from cwd (a single
      company id) → look it up in {framework-home}/companies.toml → root
   c. else, for every company in companies.toml, read its teams' `owns`
      (resolved against that company's root); a company with a team that
      owns cwd is the company — this is how a code repository kept outside
      the company repository finds its company without carrying a marker
   d. else not in a company: project-scoped operation under crux-coordinator
      alone. Ask (listing the ids in companies.toml) only when the operator
      named a company or team that did not resolve.
   {framework-home} itself is never a company, a project, or a match for any
   walk-up, even though it contains `.crux`-like directories.

2. Team
   a. for every .crux/teams/*/TEAM.md, resolve each `owns` path against the
      company root; the team whose owned path is the longest prefix of cwd
      wins — automatic
   b. no owned match → a team whose `also` contains cwd, if exactly one
   c. cwd == company root → the coordinator team named in COMPANY.md
   d. the operator named a team in the start prompt → that team, but warn if
      cwd is owned by a different team
   e. ambiguous or none → ask, listing the teams and what they own

3. Boot
   read {company-root}/.crux/COMPANY.md, CONSTITUTION.md, SOUL.md
   read .crux/teams/{team}/TEAM.md
   read the primary role's AGENT.md, and its SOUL.md if present
     (primary = the first entry of `roles`; the others load lazily when
     their domain is triggered)
   read .crux/workspace/{team}/MEMORY.md, TODO.md, NOTES.md if present —
     missing is normal; they are created on the team's first write
   read AGENTS.md files: the company's, then each one from the owned
     repository root down to cwd — the nearest to cwd is read last and wins
   read {framework-home}/skills/{task_tool}/SKILL.md when COMPANY.md has a
     `task_tool` other than `none` (see Task Tool) and run its boot step
   list .crux/requests/{team}/            ← the inbox
```

Boot is read-only. It does not run tests, onboarding, or workspace
initialisation, and it creates no files. When the coordinator team boots
with unfilled templates or teams without a paragraph under *Pending*, it
offers to resume Company Onboarding at the first unfinished step.

State locations in a company — all under the company root, never in an owned
repository:

```text
.crux/workspace/MANIFEST.md, TODO.md, inbox.md, MEMORY.md   coordinator team
.crux/workspace/{team}/MEMORY.md, TODO.md, NOTES.md          each team, owned by it
.crux/workspace/{team}/sessions/                             session summaries
```

A code repository owned by a team needs no `.crux/` of its own. If it has
one, it holds project knowledge only (`docs/`, `decisions/`); the team reads
it and writes it like any other owned path.

Role onboarding: a role's onboarding runs the first time the team does work
in that role's domain, not at boot. Its status is recorded in the company
`.crux/workspace/MANIFEST.md` under the qualified team id; no MANIFEST, or no
row for `{company}/{team}` and the role, means not onboarded. The `Status`
line inside an AGENT.md is the template default, never live state. At boot, a
role not onboarded for this team is listed under *Pending*.

Two inboxes, two names: the **board inbox** is `.crux/requests/{team}/`
(ignore `.gitkeep`); the **decision inbox** is the company
`.crux/workspace/inbox.md`, which only the coordinator team keeps.

Identity inheritance, lowest to highest precedence:

```text
company CONSTITUTION.md → company SOUL.md → primary role SOUL.md
  → TEAM.md "Soul override" → owned repository AGENTS.md rules
```

Boot report — short, then wait for instructions unless the start prompt gave
work:

```text
Crux team ready.
Company:  {company-id}  ({company-root})
Team:     {company}/{team}   roles: {roles}
Owns:     {path} — {git branch, clean|N changed | not a git repository}
          (one line per owned path)
Inbox:    {n} open, {n} accepted, {n} done-awaiting-requester  | empty
Sent:     {n} of mine done or declined, waiting for me to pick up | none
Tasks:    the task tool's boot line (its skill defines it) | none
Sessions: running sub-sessions (team session only; see Sessions) | none
Tests:    last result recorded in MEMORY.md, or "not run"
Pending:  unfilled templates ({{…}}, [e.g. …], a `*.template.md` heading or
          a "HOW TO USE THIS TEMPLATE" comment left in COMPANY.md,
          CONSTITUTION.md, SOUL.md, TEAM.md), roles not onboarded,
          TODOs waiting or blocked | none
```

To fill *Sent*, scan every `requests/*/` folder for files whose `from` is this
team and whose `status` is `done` or `declined`.

---

## Task Tool

A company may keep its tasks and approvals in a tool outside the board. The
choice is the company's, made once at onboarding and recorded in
`COMPANY.md`:

```text
task_tool: none                      the board is enough (default; a
                                     missing field means none)
task_tool: clave-workflow-manager    the skill of the chosen tool
```

The value is the name of a skill under `{framework-home}/skills/` whose
frontmatter has `metadata.category: task-tool`. Such a skill carries the
tool's working rules: identity, session naming, setup, the item loop, and
how it reports in the boot report's *Tasks* line.

Rules:

1. Coordinator and team sessions load the chosen skill at boot and no other
   task-tool skill. `none` → nothing is loaded; no session asks for a tool.
2. The tool is an additional record, never a replacement for ownership: a
   change outside the team's paths is still a request on the board.
3. Where the tool has its own approval step, it runs in addition to the
   constitution's approval rules, not instead of them.
4. Which tools are offered at onboarding is whatever is installed: list the
   skills with `category: task-tool` in framework home.

---

## Ownership

Rules:

1. A team **owns** its `owns` paths exclusively. Two teams never own the same
   path. A deeper owned path carves itself out of a shallower one: the
   coordinator owns `.`, `auth` owns `baseworks-ts/projects/auth-service`, and
   the longest match decides.
2. A team **edits** only paths it owns or lists under `also`. It commits only
   in repositories it owns.
3. Anything else is a **request** to the owning team — never a patch, not even
   one line, not even an obvious bug. A fix made in the consumer is a local
   copy the owner does not know about.
4. **Reading** is unrestricted. A consumer reads the producer's public surface
   (`README.md`, `openapi.yaml`, a client package) instead of asking.
5. Every team writes request files in **other** teams' folders (new requests)
   and in **its own** folder (status changes). Nothing else outside its
   owned and `also` paths.
6. The coordinator team owns the company root: `.crux/` knowledge,
   `AGENTS.md`, `teams/`, and the registry entry. It routes and keeps the
   board; it does no domain work.

Before any write, check:

```text
target path → longest owns-prefix across all TEAM.md
  == this team            → write
  in this team's `also`   → write
  request file per rule 5 → write
  otherwise               → open a request to the owner; do not write
```

If the check finds no owner at all, the path belongs to the coordinator team.

---

## The Board

Location: `{company-root}/.crux/requests/{owner-team}/{YYYY-MM-DD}-{slug}.md`
Template: `{framework-home}/templates/REQUEST.template.md`

The board is the filesystem transport of `{framework-home}/bus/protocol.md`:
frontmatter is the message envelope (`id`, `from`, `to`, `type`,
`parent_id`, `context_refs`), the body is the payload. Other transports may
carry the same message later; the file stays the source of truth.

### What is a request

- a missing field, endpoint, command or behaviour in something another team owns
- a bug found in another team's code while using it
- a change to a shared surface owned by another team
- an approval only a human can give (`type: approval-request`, to the
  coordinator team)

Never a request: work inside your own owned paths, or a question answered by
reading the owner's public surface.

### Handshake

```text
open ──► accepted ──► done ──► requester deletes the file
  │
  └────► declined ──► requester deletes, or opens a new request with
                      parent_id = the declined id
```

| Who | May change |
|---|---|
| requester | creates the file; deletes it after reading `done` or `declined` |
| owner | `status`, `closed`, *Owner's notes* — nothing else |

A `done` file still in a folder is a requester that has not picked it up.
A request that needs two teams is two files, each with its own id; link them
with `parent_id` when one depends on the other.

### Opening a request (requester)

```text
1. Resolve the owner of the target path (Ownership check above).
2. Look in .crux/requests/{owner}/ for an open request with the same intent.
   Found → add context to it only if you are its requester; otherwise stop
   and reference it in your own TODO.
3. Copy REQUEST.template.md to .crux/requests/{owner}/{today}-{slug}.md.
   id = new ULID, from = {company}/{me}, to = {company}/{owner},
   status = open, opened = today.
4. Write Why / What / Done when. Link the waiting code in context_refs.
5. Commit the file in the company repository, message
   "request {owner}: {title}". Touch nothing else in that commit.
   Commits follow the company constitution: if it requires explicit
   operator approval, leave the file uncommitted and say so. Sessions on
   the same machine see it either way; the commit is the record.
6. Record the dependency in .crux/workspace/{me}/TODO.md as status waiting,
   evidence_refs = the request path.
```

### Working a request (owner)

```text
1. On reading your inbox, for each open request decide:
   accept → status: accepted  (you may rewrite What in Owner's notes;
            the owner decides the shape, the requester states the need)
   decline → status: declined, closed: today, reason and alternative
            in Owner's notes
2. Create or resume a TODO in .crux/workspace/{me}/TODO.md referencing it.
3. Do the work in your owned repositories. Commit there.
4. status: done, closed: today, Owner's notes: commit id(s) and version.
5. Commit the request file change in the company repository,
   message "request {requester} done: {title}" — subject to the
   constitution, as above.
```

### Picking up (requester)

```text
done     → verify against Done when, pull/consume the new version,
           delete the file, commit the deletion, close your TODO
declined → read the reason; delete, or open a follow-up with parent_id
```

### Approvals

`type: approval-request` goes to `.crux/requests/{coordinator}/`. The
coordinator surfaces it in `.crux/workspace/inbox.md` under *Pending
Approvals*, gets the human decision there, and answers in the file:
`status: done` (approved) or `declined` (rejected), with the decision and any
conditions in *Owner's notes*. The requesting team blocks the related TODO
(`waiting`) until then.

### Cross-company

`to: {other-company}/{team}` resolves through `companies.toml` to
`{other-root}/.crux/requests/{team}/`. The file is committed in the owner's
company repository. Allowed; use only when the operator asks for it.

### Notifications

A host that can ping another session may be used to say "you have mail".
The notification is never the message: the file is.

---

## Session Start

```text
1. Resolution (above) → company, team, boot report.
2. Inbox first: open requests are read before new work is taken.
3. Sent: pick up any of your requests that are done or declined.
4. Resume open TODOs in .crux/workspace/{team}/TODO.md before creating new ones.
```

## Sessions

Where the host can run several sessions at once, a company works in three
levels. A session's title is its name below.

```text
level         name                            cwd                       started by
coordinator   {company} company               company root              the operator
team session  {company}/{team} team session   the team's first `owns`   the coordinator (or operator)
sub-session   {company}/{team}/{project}      the repository folder     its team session
```

- **Coordinator session** — the coordinator team. Starts team sessions;
  never opens sub-sessions itself.
- **Team session** — the team. Keeps the board inbox
  (`.crux/requests/{team}/`) and the team's task-tool items, decides what
  runs where, and starts one sub-session per repository that has work.
- **Sub-session** — the same team identity (same company, team, roles,
  task-tool identity), scoped to one repository. `{project}` is that
  repository's task-tool key, else its directory name. It does the work it
  was given, reports to its team session, and does not take board requests
  on its own; anything for another team still goes through the board.

Rules:

1. A team with a single repository needs no sub-session: the team session
   works there.
2. Sessions are opened on demand, never to idle. A team with no open
   request, item or TODO has no session; the coordinator opens one when
   work lands for it or the operator asks.
3. One team session per team, one sub-session per repository at a time.
4. A sub-session ends when its work is done; its result (commits, closed
   items) is relayed to the team session, which updates the board.
5. The session title is a Crux name; a task tool's own session or step
   label stays as its skill defines it.

The team session's boot report adds:

```text
Sessions: {project} — {state}, one per running sub-session | none
```

## Ending a Piece of Work

```text
1. Tests green in the owned repositories touched.
2. Committed in those repositories; the message explains the decision.
3. Requests completed are `done` with commit id and version, committed at
   the company.
4. Requests opened sit in the owner's folder, committed at the company.
5. If this team's public surface changed, each consumer that needs the change
   has a request — the team does not update consumers itself.
6. Durable facts → .crux/workspace/{team}/MEMORY.md; TODO statuses current.
```

Nothing is published or deployed as part of ending work unless the team's
role and the constitution say so.

---

## Coordinator Team

The coordinator is a team like any other, with three extra duties:

- **Routing by ownership** — for a request about a path or repository, find
  its owning team and write a request there; never edit it from the root.
- **Board keeping** — list stale requests in its boot report: `open` or
  `accepted` with `opened` older than 7 days, `done`/`declined` with
  `closed` older than 7 days and not yet deleted. It does not change their
  status. The company constitution may set another threshold.
- **Approvals** — turn `requests/{coordinator}/` approval-requests into
  `workspace/inbox.md` entries and answer them.

Cross-team workflows are a sequence of requests linked by `parent_id`. The
coordinator owns the sequence; each team owns its step.

---

## Company Onboarding

Creates a company with the operator, step by step, in the session opened at
the future company root. Writes go through `{framework-home}/scripts/company.sh`
where it has a command, and are edits to the created files otherwise.

Triggers:

- coordinator workspace initialisation, when the operator chooses *company*
- the operator asks to create or set up a company here
- the coordinator team boots with *Pending* items, and the operator asks to
  finish them — onboarding resumes at the first unfinished step

Conduct:

- One step per message. Say what the step decides, propose a default from
  what you can see, and wait for the answer.
- Write only after the operator confirms the step, then show what changed
  (file and the relevant lines).
- Never commit, never create a git repository, never touch an owned code
  repository without an explicit yes for that action.
- Speak the operator's language; files may stay in English unless the
  operator's SOUL answer says otherwise.
- If the operator stops, stop. Boot's *Pending* line is the resume point.

Steps:

```text
1. Identity
   ask: id (lowercase slug), display name, one sentence on what the company is
   propose: id from the parent directory name, sentence from nearby READMEs
   write: company.sh init <id> --root . --name <name> --description <text>
          (creates .crux/, AGENTS.md, .gitignore, coordinator team, and the
          companies.toml entry — say so before running)

2. Git
   check: is the root a git repository?
   ask: create one here? (the company repository holds no code; code
        repositories stay separate)
   write: git init — only on yes

3. Constitution  (.crux/CONSTITUTION.md)
   walk the rules briefly; ask each {{…}} choice:
     - may teams commit request files without asking?  yes | no
     - days before an unanswered request is surfaced   default 7
   ask: any company rule to add (e.g. sensitive-data handling, deploy rules)
   write: replace the placeholders, append added rules

4. Soul  (.crux/SOUL.md)
   ask: working language, tone, behavioural overrides every team inherits
   write: the filled SOUL.md, template heading removed

5. Task tool  (COMPANY.md → task_tool)
   look: skills in {framework-home}/skills/ whose metadata says
         `category: task-tool`
   ask, without naming a product first: does the company want a tool for
        task and approval management? Options: each installed task-tool
        skill by the tool it serves (metadata.tool), or none — the board
        alone.
   write: `task_tool: <skill-name>` or `task_tool: none` in COMPANY.md.
          Nothing is installed or configured here; the chosen skill's own
          setup section says what each person runs before opening a
          session. Say so.
   skip: no task-tool skill installed → write `none`, mention it, move on

6. Teams — discover
   look: the directories beside the company root (and any the operator
         names): for each, git status, README/AGENTS.md first lines, stack
         markers (package.json, pyproject, Makefile, infra/), sensitive files
         (statements, exports, .env, keys)
   propose: a table — one team per repository by default, with id, roles
            from {framework-home}/agents/ (first = primary), owns (../repo),
            and a one-line purpose. Teams split later, when an inbox gets
            crowded; do not propose more than the repositories justify.
   ask: confirm, rename, merge, drop, or add teams

7. Teams — create, one at a time
   per confirmed team:
     write: company.sh team add <id> --role <r1,r2> --owns <paths> [--also …]
     write: its paragraph in TEAM.md (what it owns, who consumes it, what it
            never does; a sensitive-data line when step 6 found any)
     ask: soul override for this team? (usually none)

8. Coordinator team
   write: its paragraph — routes, keeps the board, owns the company
          repository, does no domain work; its role is
          `company-coordinator` (set by company.sh init)

9. Check
   run: company.sh resolve <path> for every owned path and for the root
   show: company, teams, owned paths, resolution result per path
   require: Pending = none (re-read files for {{…}}, [e.g. …], template
            headings and HOW TO USE comments)

10. Commit
   ask: commit the company repository now?
   write: one commit, "Found {company}: teams and constitution" — only on yes

11. Hand-off
   tell the operator how to start each team: open a session in the owned
   repository (it resolves to the team), or at the company root for the
   coordinator. If a task tool was chosen, point at its skill's setup
   section: what each person runs in each repository before the first
   session there. Nothing else is started automatically.
```

---

## Team Changes

Adding a team, changing `owns`, or splitting a team is a coordinator action:

```text
1. Copy {framework-home}/templates/TEAM.template.md to
   .crux/teams/{team}/TEAM.md and create .crux/requests/{team}/.
2. Check exclusivity: no other team owns the same path.
3. Commit at the company root.
```

Teams split when an inbox gets crowded, not before.

Changing the task tool (`COMPANY.md` → `task_tool`) is also a coordinator
action, on the operator's explicit yes: edit the field, commit at the
company root, and tell every team to open new sessions — a running session
keeps the skill it booted with.

---

## Failure Handling

| Condition | Action |
|---|---|
| no COMPANY.md and no registry match | Not a company — fall back to crux-coordinator |
| `.crux/company` names an unregistered id | Report it; ask for the root, suggest `crux company init` |
| two teams own the same path | Stop; report both TEAM.md files to the coordinator team |
| cwd owned by no team | Coordinator team owns it; ask before acting as coordinator |
| request frontmatter malformed | Do not guess status; ask the requester to fix it |
| status changed by a non-owner | Report it; do not act on the changed status |
| owner absent for a blocking request | Leave it open; surface it in the boot report and the coordinator inbox |
| `task_tool` names a skill not in framework home | Boot without it; report `Tasks: {name} — skill not installed`; do not fall back to another tool |

---

## Output

A boot report (above), and, per piece of work: files written in owned paths,
request files created or changed, commits made and in which repository.
