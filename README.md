# Crux

> Markdown-native, lazy-loading, multi-agent workspace.
> Every rule, every identity, every protocol lives in a plain text file.
> No runtime required to read or understand what the system is doing.

---

## Installation

### Quick start

```sh
curl -fsSL https://raw.githubusercontent.com/dotlabshq/crux/main/scripts/install.sh | bash
```

### With options

```sh
curl -fsSL https://raw.githubusercontent.com/dotlabshq/crux/main/scripts/install.sh | bash -s -- \
  --tool opencode
```

| Option | Description | Default |
|---|---|---|
| `--agents` | Comma-separated agent IDs to install | all available |
| `--tool` | Target AI tool: `opencode` · `claude-code` · `cursor` · `all` | auto-detect |
| `--project` | Project name used during workspace initialisation | — |
| `--force` | Overwrite existing `.crux/` files | false |
| `--dry-run` | Preview without writing files | false |

### After install

Start your AI tool in the project directory. The install script places the framework under `.crux/`. On first launch, the coordinator runs workspace initialisation and onboarding to generate project-specific files from user answers.

```
@kubernetes-admin   cluster health, namespaces, tenant provisioning
@postgresql-admin   schema inspection, roles, backups, tenant provisioning
```

### Keeping agents in sync

After editing any `.crux/agents/` or `.crux/skills/` file, re-run:

```sh
./scripts/convert.sh
```

This syncs agent and skill definitions to tool-specific locations (`.opencode/agent/`, `.claude/agents/`, `.cursor/rules/`).

### Updating from the Crux repo

To pull the latest agent, skill, and framework files from the upstream Crux repo:

```sh
./scripts/update.sh
```

This overwrites `.crux/agents/`, `.crux/skills/`, and framework files with the latest versions, then re-runs `convert.sh`. Local customisations to those files will be lost — commit them first if you want to preserve them.

```sh
# Update specific agents only
./scripts/update.sh --agents kubernetes-admin,postgresql-admin

# Preview without writing
./scripts/update.sh --dry-run
```

---

## Directory Structure

This section describes the installed runtime shape inside a user project.
If you are working on the Crux framework repository itself, see [docs/source-layout.md](docs/source-layout.md) for source-layout vs installed-layout rules.

```
.crux/
│
│   ── Framework (committed) ─────────────────────────────────
├── COORDINATOR.md         Boot logic, agent lifecycle, @mention routing.
├── AGENTS.md              Project status, conventions, design decisions.
│
├── templates/             Framework starter files.
│   ├── CONSTITUTION.template.md
│   ├── SOUL.template.md
│   ├── MANIFEST.template.md
│   ├── MEMORY.template.md
│   ├── NOTES.template.md
│   ├── AGENT.template.md
│   ├── SKILL.template.md
│   ├── WORKFLOW.template.md
│   ├── DECISION.template.md
│   ├── onboarding.template.md
│   └── skills/
│       └── example-skill/
│           └── SKILL.md
│
├── agents/                Agent identity and behaviour — versioned.
│   └── {role-id}/
│       ├── AGENT.md       Frontmatter + role definition + context budget.
│       ├── SOUL.md        Agent-level tone overrides (optional).
│       ├── onboarding.md  Onboarding sequence for this agent.
│       └── assets/        Agent-local source material for generated docs.
│
├── skills/                Single-responsibility task units. Owned by one agent.
│   └── {skill-name}/
│       └── SKILL.md
│
├── workflows/             Multi-agent workflows. Orchestrated by coordinator.
│   └── {name}.md          Each step delegates to one agent + one skill.
│
├── decisions/             Generated project decisions (ADR-lite).
│   └── {id}.md            Created during onboarding or approval flow.
│
├── docs/                  Generated on demand after onboarding.
│                         Created from owning agent assets or local templates.
│   └── {topic}.md
│
├── summaries/             Token-efficient summaries of docs/ files.
│   └── {topic}.md
│
├── bus/                   Inter-agent messaging.
│   ├── protocol.md        Transport-agnostic message schema.
│   ├── broadcast.jsonl    System-wide events.
│   └── {role-id}/
│       └── to-{target}.jsonl
│
│   ── Generated during onboarding / first boot ──────────────
├── CONSTITUTION.md        Generated from template + user answers.
├── SOUL.md                Generated from template + user answers.
│
│   ── Dynamic (gitignored) ───────────────────────────────────
└── workspace/
    ├── MANIFEST.md        Live system state — agent status, pending amendments.
    ├── inbox.md           Human approvals, handoffs, and pending operator decisions.
    ├── MEMORY.md          Coordinator persistent memory.
    ├── current            Symlink → sessions/{active-ulid}/
    ├── sessions/          Coordinator sessions.
    │   └── {ulid}/
    │       ├── scratch.md
    │       ├── context-cache.md
    │       └── summary.md
    │
    └── {role-id}/         Per-agent workspace.
        ├── MEMORY.md      Agent persistent memory — facts, decisions, conventions.
        ├── NOTES.md       Operational state — issues, pending tasks, discoveries.
        ├── output/        Files generated by this agent. Persistent.
        ├── current        Symlink → sessions/{active-ulid}/
        └── sessions/
            └── {ulid}/
                ├── scratch.md
                ├── context-cache.md
                └── summary.md
```

---

## Static vs Dynamic

| Path | Type | Git | Created by |
|---|---|---|---|
| `CONSTITUTION.md` | generated static | after onboarding | coordinator during workspace initialisation |
| `SOUL.md` | generated static | after onboarding | coordinator during workspace initialisation |
| `COORDINATOR.md` | static | ✓ | manual — always present |
| `AGENTS.md` | static | ✓ | manual — always present |
| `../README.md` | static | ✓ | manual — project root, human docs |
| `templates/*` | static | ✓ | manual — always present |
| `agents/{role}/AGENT.md` | static | ✓ | manual from template |
| `agents/{role}/onboarding.md` | static | ✓ | manual from template |
| `skills/{name}/SKILL.md` | static | ✓ | manual from template |
| `workflows/{name}.md` | static | ✓ | manual from template |
| `decisions/{id}.md` | generated static | after onboarding | agent proposes + user approves, OR coordinator generates during onboarding |
| `.crux/docs/{topic}.md` | generated static | after onboarding | onboarding, lazy-loading, or skills from owning agent assets |
| `summaries/{topic}.md` | static | ✓ | doc-summariser skill |
| `bus/protocol.md` | static | ✓ | manual — always present |
| `.crux/workspace/` | dynamic | ✗ | coordinator during workspace initialisation |
| `.crux/workspace/MANIFEST.md` | dynamic | ✗ | coordinator during onboarding / workspace initialisation |
| `.crux/workspace/MEMORY.md` | dynamic | ✗ | coordinator during onboarding / workspace initialisation |
| `.crux/workspace/inbox.md` | dynamic | ✗ | coordinator during onboarding / workspace initialisation |
| `.crux/workspace/sessions/{ulid}/` | dynamic | ✗ | coordinator at session start |
| `.crux/workspace/{role}/MEMORY.md` | dynamic | ✗ | onboarding |
| `.crux/workspace/{role}/NOTES.md` | dynamic | ✗ | onboarding |
| `.crux/workspace/{role}/sessions/{ulid}/` | dynamic | ✗ | coordinator at session start |

---

## Context Loading Order

Every agent loads files in this order:

```
1. .crux/CONSTITUTION.md                    ~1000 tokens   always
2. .crux/SOUL.md                            ~500  tokens   always
3. .crux/agents/{role}/AGENT.md             ~800  tokens   always
4. .crux/workspace/{role}/MEMORY.md         ~400  tokens   always
─────────────────────────────────────────────────────────────────
Base cost:                                  ~2700 tokens

5. .crux/workspace/{role}/NOTES.md          session start  issues + pending tasks
6. .crux/summaries/{doc}.md                 on demand      overview sufficient
7. .crux/docs/{doc}.md                      on demand      generate if missing, then load
8. .crux/decisions/{id}.md                  on demand      when decision is referenced
9. .crux/skills/{name}/SKILL.md             on trigger     unloaded after use
```

Coordinator additionally loads on workflow trigger:
```
.crux/workflows/{name}.md                   on trigger     unloaded after workflow completes
```

Hard limit: **8000 tokens** before execution begins.

---

## Three Layers

```
.crux/              static      who we are        committed, versioned
.crux/workspace/    dynamic     what we know      gitignored, live state
.crux/workspace/sessions/ ephemeral   what coord did    gitignored, coordinator sessions
.crux/workspace/{role}/sessions/ ephemeral  what agents did   gitignored, per-agent sessions
```

---

## Onboarding Flow

When an agent starts and `.crux/workspace/MANIFEST.md` shows `status: pending-onboard`:

```
1. Run environment discovery (silent checks)
2. Ask user only what could not be discovered
3. Generate missing `.crux/docs/` references from the agent's assets if needed
4. Run required skills → generate project docs, decisions, or notes-root content
5. Write facts to `.crux/workspace/{role}/MEMORY.md`
6. Create `.crux/workspace/{role}/NOTES.md` from template
7. Update `.crux/workspace/MANIFEST.md` status → onboarded
8. Broadcast agent.onboarded event
```

---

## Workflow Flow

When the coordinator detects a workflow trigger phrase:

```
1. Load .crux/workflows/{name}.md
2. Collect inputs from user (one at a time, validate before proceeding)
3. For each step:
     a. Check owning agent is onboarded (`.crux/workspace/MANIFEST.md` status == onboarded)
        not onboarded + required: yes  → stop
        not onboarded + required: no   → skip, continue
     b. Delegate to agent via @mention, passing inputs
     c. Record step result in `.crux/workspace/sessions/{id}/scratch.md`
4. Coordinator runs Finalise: update `.crux/workspace/MANIFEST.md`, broadcast event, notify user
5. On required step failure → run rollback as defined in workflow file
```

---

## Amendment Flow

```
1. Agent writes AMD-{id} to `.crux/workspace/MANIFEST.md` → Pending Amendments
2. Agent pauses and notifies user
3. User approves → .crux/CONSTITUTION.md updated, version incremented
4. User rejects → agent continues under current rule
```

---

## @Mention Modes

| Mode | Behaviour |
|---|---|
| `primary` | Direct handoff in same context (Tab switcher) |
| `subagent` | Invoked via @mention or by primary agent |

---

## .gitignore

```
.crux/workspace/
```

Everything under `.crux/workspace/` is gitignored. All static `.crux/` files are committed.
Generated `.crux/docs/`, `decisions/`, project `docs/`, and any user-selected notes root are created during onboarding or lazy-loading, not pre-populated in the repo.

---

## Adding Agents, Skills, and Workflows

```
Agent:    copy templates/AGENT.template.md      → agents/{role}/AGENT.md
          copy templates/onboarding.template.md → agents/{role}/onboarding.md
          add agent-local assets under          → agents/{role}/assets/   (if the agent generates `.crux/docs/*`)
          run: ./scripts/convert.sh

Skill:    copy templates/SKILL.template.md      → skills/{name}/SKILL.md
          run: ./scripts/convert.sh

Workflow: copy templates/WORKFLOW.template.md   → workflows/{name}.md
          update `.crux/workspace/MANIFEST.md` Workflows table
```

## Three-Layer Model

| Concept | Where | Scope | Git |
|---|---|---|---|
| **Skill** | `skills/{name}/SKILL.md` | One agent, one task | ✓ |
| **Workflow** | `workflows/{name}.md` | Coordinator + multiple agents | ✓ |
| **Decision** | `decisions/{id}.md` | Human-approved, permanent record | ✓ |
| **Doc** | `docs/{topic}.md` | Generated knowledge, replaceable | ✓ |
| **Memory** | `.crux/workspace/{role}/MEMORY.md` | Agent runtime state | ✗ |
## Source vs Installed

Crux keeps a strict separation between framework source and project runtime:

- Source repo layout is for framework development only.
- Installed layout is the only valid runtime/documentation model.
- All architecture documents must reference installed paths.
- Install script maps source layout into installed `.crux/`.
- Generated docs, summaries, workspace, and user outputs must never be committed as source framework content.

See [docs/source-layout.md](docs/source-layout.md) for the explicit mapping table and generation rules.
