# Crux

This project uses the Crux multi-agent workspace framework.

## Boot Instructions

On every session start:
1. Read `.crux/COORDINATOR.md` — boot sequence and routing rules
2. Read `.crux/CONSTITUTION.md` — universal rules (if it exists)
3. Read `.crux/SOUL.md` — identity and tone defaults (if it exists)
4. Read `.crux/workspace/MANIFEST.md` — current system state (if it exists)
   - If workspace/ does not exist → run installation as described in COORDINATOR.md
5. Surface any pending items (agents pending onboard, amendments, open sessions)

## Agents

Sub-agents are defined in `.claude/agents/`. Each handles a bounded domain.
Type `@{role-id}` to activate an agent. The coordinator routes all @mentions.

## Key Paths

| Path | Purpose |
|---|---|
| `.crux/COORDINATOR.md` | Boot + routing logic |
| `.crux/agents/{role}/AGENT.md` | Agent identity (source of truth) |
| `.crux/skills/{name}/SKILL.md` | Skill definitions |
| `.crux/workflows/{name}.md` | Multi-agent workflows |
| `.crux/decisions/` | Approved architectural decisions |
| `.crux/workspace/` | Live state — gitignored |

Do not modify `.crux/agents/` files during a session.
Do not write to `.crux/workspace/` without following COORDINATOR.md protocols.