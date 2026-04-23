# Crux Source Layout vs Installed Layout

Crux has two valid filesystem views:

1. `source layout`
   The framework repository used to develop and package Crux itself.
2. `installed layout`
   The runtime shape inside a user project after Crux is installed.

The installed layout is the only valid runtime and documentation model.
All architecture documents should describe paths as they appear inside the user project.

## Rules

These rules are mandatory:

1. Source repo layout is for framework development only.
2. Installed layout is the only valid runtime/documentation model.
3. All architecture documents must reference installed paths.
4. Install script is responsible for mapping source layout into installed `.crux/`.
5. Generated docs, summaries, workspace, and user outputs must never be committed as source framework content.

## Source Layout

This is the framework repository shape used by Crux maintainers.

```text
/
├── agents/
├── skills/
├── templates/
├── workflows/
├── bus/
├── scripts/
├── docs/
├── README.md
└── CONTRIBUTING.md
```

Notes:
- This layout exists to make the framework easier to maintain and package.
- Source paths are not the paths that runtime agents should reason about.
- Agent and skill content may be authored here, but the text inside those files should still refer to installed `.crux/...` paths.

## Installed Layout

This is the runtime shape inside a user project.

```text
.crux/
├── COORDINATOR.md
├── AGENTS.md
├── CONSTITUTION.md
├── SOUL.md
├── agents/
├── skills/
├── templates/
├── workflows/
├── bus/
├── docs/
├── summaries/
└── workspace/
```

This is the only layout that architecture and runtime documentation should reference.

## Mapping

Install maps framework source into the user project's `.crux/` directory:

| Source repo path | Installed path |
|---|---|
| `agents/*` | `.crux/agents/*` |
| `skills/*` | `.crux/skills/*` |
| `templates/*` | `.crux/templates/*` |
| `workflows/*` | `.crux/workflows/*` |
| `bus/*` | `.crux/bus/*` |
| `COORDINATOR.md` | `.crux/COORDINATOR.md` |
| `AGENTS.md` | `.crux/AGENTS.md` |

## Copy vs Generate

### Copied by install

- `.crux/COORDINATOR.md`
- `.crux/AGENTS.md`
- `.crux/agents/*`
- `.crux/skills/*`
- `.crux/templates/*`
- `.crux/workflows/*`
- `.crux/bus/*`

### Generated during onboarding / first boot

These depend on user answers and project-specific setup, so install should not create them up front:

- `.crux/CONSTITUTION.md`
- `.crux/SOUL.md`
- `.crux/workspace/MANIFEST.md`
- `.crux/workspace/MEMORY.md`
- `.crux/workspace/inbox.md`
- `.crux/workspace/{role}/MEMORY.md`
- `.crux/workspace/{role}/NOTES.md`
- generated project decisions
- user-space outputs such as `notes/`, `operations/`, or `docs/compliance/`

### Generated lazily on demand

- `.crux/docs/{topic}.md`
- `.crux/summaries/{topic}.md`
- agent-specific reference docs generated from `agents/{role}/assets/`
- workflow outputs and role-specific generated files

## Path Standard

Even when a file is authored in the source repository as:

```text
agents/backend-developer/AGENT.md
```

its documentation should still refer to:

```text
.crux/agents/backend-developer/AGENT.md
```

The same rule applies to skills, workflows, templates, bus files, docs, summaries, and workspace files.

## Why This Split Exists

This split keeps two concerns separate:

- framework development and packaging
- project runtime and user-facing documentation

That separation avoids leaking generated project state back into the framework repository and keeps runtime documentation stable even if the framework repo layout changes later.
