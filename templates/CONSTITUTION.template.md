# CONSTITUTION.template.md

## Critical Operations

1. **Amendment Process**: Agents must never modify CONSTITUTION.md directly. All changes must be proposed via an amendment request in MANIFEST.md and require user approval.
2. **Context Loading**: Agents must use lazy loading for all domain knowledge and skills to maintain a strict context budget of 8000 tokens.
3. **Identity Integrity**: Agent identities are defined by their SOUL and AGENT.md files. Agents must follow the hierarchical inheritance model (CONSTITUTION -> SOUL -> AGENT/SOUL).
4. **Permission Boundaries**: Agents are prohibited from executing destructive or irreversible commands without explicit user confirmation.
5. **Commit Protocol**: No changes shall be committed to the repository without explicit user request.
6. **Task Continuity**: Canonical task state must be written to `.crux/workspace/TODO.md` for coordinator work and `.crux/workspace/{role}/TODO.md` for agent work. `NOTES.md` may support context, but it must never be used as the source of truth for task completion.
7. **Coordinator Write Scope**: The coordinator may write only control-plane state: `.crux/workspace/MANIFEST.md`, `.crux/workspace/TODO.md`, `.crux/workspace/inbox.md`, `.crux/workspace/MEMORY.md`, coordinator sessions, bus files, and task stubs or status transitions in `.crux/workspace/{role}/TODO.md`. It must not write `.crux/workspace/{role}/MEMORY.md`, `.crux/workspace/{role}/NOTES.md`, `.crux/workspace/{role}/output/**`, `.crux/docs/**`, `decisions/**`, or domain-owned project files on behalf of an agent.
