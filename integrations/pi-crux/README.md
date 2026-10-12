# pi-crux

A [Pi](https://github.com/earendil-works/pi) extension that enforces Crux rules
in code. Crux is markdown-native: every rule lives in a file and, in most
tools, the model is trusted to follow it. Pi has no built-in sub-agents, plan
mode or permission system, so this package adds the parts Crux needs.

| Feature | What it does | Where the rule comes from |
|---|---|---|
| Boot | Resolves the company and team (or the project) from `cwd` at session start; silently disabled outside Crux | `skills/crux-team/SKILL.md` § Resolution |
| Context budget | Estimates the base context (constitution, soul, AGENT.md, MEMORY, TODO) and warns above 8000 tokens; shown in the footer as `crux b9/mail · base 2.1k/8k` | README § Context Loading Order |
| Write guard | Blocks `write`/`edit` (and obvious `bash` writes) outside the coordinator write scope and, in a company, outside the team's `owns`/`also` paths; framework home is always read-only | README § Task State Model, `crux-team` § Ownership |
| `crux_delegate` | Opens a `T-<ulid>` record in the role's TODO.md, runs the role in a separate `pi --mode json -p` process, reports the record's final status. Complete only when it reads `done` | `crux-coordinator` § Agent Start/Stop |
| `/crux-inbox` | Lists the team's request board (`.crux/requests/<team>/`), answered requests it sent, and the coordinator's pending `inbox.md` items | `crux-team` § The Board |

The rules are one data structure, `WRITE_RULES` in `src/crux/rules.ts`, with
glob patterns and placeholders (`{workspace}`, `{owns}` …). A later version can
read the same table from markdown.

## Install

```sh
$HOME/.crux/scripts/convert.sh --tool pi        # skills link + role templates
pi install $HOME/.crux/integrations/pi-crux     # this extension, loaded in place
```

Or for one run: `pi -e $HOME/.crux/integrations/pi-crux`.

## How a session looks

```
/kubernetes-admin check the prod namespace    ← role template sets the active role
crux project:kubernetes-admin · base 2.4k/8k ← footer status from pi-crux
```

At the root of a company, or inside a repository a team owns, the team is
resolved automatically and its inbox is in the system prompt. A write to a
path another team owns is blocked with the owner's name and the request
folder to use instead.

## Delegation

`crux_delegate(role, task)`:

1. In a company, `role` must be one of the current team's roles — work for
   another team is a request file, never a delegation.
2. The role must be `onboarded` in `workspace/MANIFEST.md`.
3. A task record is appended to `workspace/<role>/TODO.md` (status `todo`).
4. A child `pi` runs with `CRUX_ROLE=<role>`, no session, no context files, and
   a system prompt listing the role's load order and the task id. The guard
   runs in the child too, as the role.
5. The tool returns the child's final message and the record's status. Only
   `done` means complete.

The child needs a configured model and API key; `pi-crux` does not add one.

## Development

```sh
npm install
npm test          # vitest: parsers, resolution, guard, delegation arguments
npm run typecheck # tsc against the Pi 1.1.0 types
CRUX_HOME=... node test/smoke.mjs <project-with-.crux>   # drive the real module without a model
```

`test/smoke.mjs` loads `src/extension.ts` the way Pi does (jiti), fakes the
`ExtensionAPI`, and prints what the guard blocks and allows for the
coordinator and for a role.

Pi loads `src/extension.ts` directly through jiti; there is no build step.

## Known limits

- `bash` is guarded by scanning the command text for redirects, `tee`,
  `sed -i`, `cp`/`mv`/`rm`/`touch`/`mkdir`. Writes made by scripts, programs
  or heredocs are not seen (TODO: a sandboxed `bash` or an allow-list).
- The active role is detected from the `/<role>` prompt templates
  (`Take the Crux role …`) or `CRUX_ROLE`; a role chosen in free text is not.
- Onboarding status is read from MANIFEST.md but not run (TODO: offer the
  role's `onboarding.md` when the record says `pending-onboard`).
- Token estimates are `length / 4`, not the model's tokenizer.
