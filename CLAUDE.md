# Crux

This repository is the **Crux framework source**. Installed, its contents map
into framework home (`$HOME/.crux`, or `CRUX_HOME`). It is not a project
runtime: there is no `.crux/` here.

In the dotlabs company this repository is owned by the `crux` team
(`dotlabs/crux`). The coordinator uses Crux; it does not develop it.

## Boot Instructions

On every session start:
1. Read `skills/crux-coordinator/SKILL.md` — path model, routing, project protocol
2. Read `skills/crux-team/SKILL.md` — companies, teams, ownership, the request board
3. If this checkout sits inside a Crux company (a parent with `.crux/COMPANY.md`),
   resolve the team and read its inbox as `crux-team` describes
4. Read `CONTRIBUTING.md` and `docs/source-layout.md` before changing layout

## Layout

| Source path | Installs to | Purpose |
|---|---|---|
| `agents/{role}/AGENT.md` | `{framework-home}/agents/` | Role identity (source of truth) |
| `skills/{name}/SKILL.md` | `{framework-home}/skills/` | Skill definitions |
| `templates/` | `{framework-home}/templates/` | Project, company, team and request templates |
| `workflows/` | `{framework-home}/workflows/` | Multi-agent workflows |
| `bus/protocol.md` | `{framework-home}/bus/` | Message schema; the request board is its file transport |
| `scripts/` | `{framework-home}/scripts/` | install, update, convert, company |
| `integrations/pi-crux/` | `{framework-home}/integrations/` | Pi extension enforcing Crux rules (guard, budget, delegate, inbox) |
| `docs/` | — | Design notes (e.g. `docs/company-model.md`) |

Never installed or overwritten: `{framework-home}/companies.toml` (company
registry) and `{framework-home}/local/` (operator-private).

Runtime paths, for reference when writing framework text:

| Path | Purpose |
|---|---|
| `{project}/AGENTS.md` | Project bootstrap → crux-coordinator |
| `{project}/.crux/` | Project knowledge (`docs/`, `summaries/`, `decisions/`) and `workspace/` |
| `{company-root}/.crux/COMPANY.md` | Marks a company |
| `{company-root}/.crux/teams/{team}/TEAM.md` | Who owns what |
| `{company-root}/.crux/requests/{team}/` | The board — each team's inbox |

## Rules

- Framework text refers to installed paths (`{framework-home}/…`, `.crux/…`),
  not source paths — see `CONTRIBUTING.md`.
- Scripts must stay bash 3.2 compatible and have a PowerShell twin.
- Do not write project or company state into this repository.
