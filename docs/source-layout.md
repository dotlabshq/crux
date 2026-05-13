# Crux Source, Framework Home, and Project Runtime

Crux has three filesystem views. They must stay separate.

1. `source layout`
   The framework repository used to develop and package Crux itself.
2. `framework home`
   The user's reusable Crux installation, normally `$HOME/.crux`.
3. `project runtime`
   A project's living `.crux/` directory.

The framework home is treated as read-mostly during project work. A project
must not write learned knowledge, workspace state, sessions, or generated
project docs back into `$HOME/.crux`.

## Rules

These rules are mandatory:

1. Source repo layout is for framework development only.
2. Framework home stores reusable definitions: agents, skills, templates,
   workflows, framework docs, and the coordinator protocol skill.
3. Project `.crux/` stores project-specific generated knowledge and live state.
4. `.crux/docs/`, `.crux/summaries/`, and `.crux/decisions/` are the compiled
   project knowledge layer and may be committed.
5. `.crux/workspace/` is live runtime state and is normally gitignored.
6. Runtime code is optional and belongs to a later `crux-runtime` phase; all
   skills must remain useful as plain markdown instructions.

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
- Source paths are not project runtime paths.
- Agent and skill content may be authored here, but reusable framework paths
  should be described as `{framework-home}/...`.
- Project paths should be described as `.crux/...` relative to the project root.

## Framework Home

Framework install maps source files into the user's framework home:

```text
$HOME/.crux/
├── AGENTS.md
├── COORDINATOR.md                 legacy coordinator document
├── agents/
├── skills/
│   └── crux-coordinator/
│       └── SKILL.md               coordinator/project-operation protocol
├── templates/
├── workflows/
├── bus/
└── docs/
```

The framework home can be manually edited by the user or replaced during a Crux
upgrade. Agents should read from it but should not write project discoveries or
project state there.

## Project Runtime

Each project has its own living `.crux/` directory:

```text
{project}/.crux/
├── CONSTITUTION.md
├── SOUL.md
├── docs/
├── summaries/
├── decisions/
├── workflows/                     project-specific generated workflows, if any
├── bus/                           project-local event/bus files, when enabled
└── workspace/
    ├── MANIFEST.md
    ├── TODO.md
    ├── inbox.md
    ├── MEMORY.md
    ├── sessions/
    └── {role-id}/
        ├── MEMORY.md
        ├── TODO.md
        ├── NOTES.md
        ├── output/
        └── sessions/
```

`.crux/docs/`, `.crux/summaries/`, and `.crux/decisions/` are the project
compiled-knowledge layer. `.crux/workspace/` is live state.

## Mapping

| Source repo path | Framework home path |
|---|---|
| `agents/*` | `$HOME/.crux/agents/*` |
| `skills/*` | `$HOME/.crux/skills/*` |
| `templates/*` | `$HOME/.crux/templates/*` |
| `workflows/*` | `$HOME/.crux/workflows/*` |
| `bus/*` | `$HOME/.crux/bus/*` |
| `COORDINATOR.md` | `$HOME/.crux/COORDINATOR.md` |
| `AGENTS.md` | `$HOME/.crux/AGENTS.md` |

Generated project files are not copied from source into framework home. They
are created under `{project}/.crux/` during onboarding or lazy-loading.

## Generated During Onboarding

These depend on user answers and project-specific setup:

- `.crux/CONSTITUTION.md`
- `.crux/SOUL.md`
- `.crux/workspace/MANIFEST.md`
- `.crux/workspace/MEMORY.md`
- `.crux/workspace/inbox.md`
- `.crux/workspace/{role}/MEMORY.md`
- `.crux/workspace/{role}/TODO.md`
- `.crux/workspace/{role}/NOTES.md`
- `.crux/decisions/{id}.md`
- user-space outputs such as `notes/`, `operations/`, or `docs/compliance/`

## Generated Lazily

- `.crux/docs/{topic}.md`
- `.crux/summaries/{topic}.md`
- `.crux/workflows/{workflow}.md` when a project-specific workflow is generated
- `.crux/workspace/{role}/output/**`

## Path Standard

Use `{framework-home}` when referring to reusable Crux definitions:

```text
{framework-home}/agents/backend-developer/AGENT.md
{framework-home}/skills/service-implementation/SKILL.md
{framework-home}/templates/AGENT.template.md
```

Use `.crux/` when referring to project knowledge or live state:

```text
.crux/docs/backend.md
.crux/summaries/backend.md
.crux/decisions/tenant-naming-conventions.md
.crux/workspace/backend-developer/MEMORY.md
```

This split keeps reusable framework upgrades separate from each project's
learned knowledge and operational state.
