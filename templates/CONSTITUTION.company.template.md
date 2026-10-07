# Constitution — {{COMPANY_NAME}}

> Company-wide rules. Every team inherits them; a team's TEAM.md and an owned
> repository's AGENTS.md may add rules but not relax these.
> Protocol: {framework-home}/skills/crux-team/SKILL.md

## Critical Operations

1. **Amendment Process**: No team modifies this file directly. A change is an
   `approval-request` to the coordinator team; the operator decides in
   `.crux/workspace/inbox.md`.
2. **Ownership**: A team writes only the paths it owns or lists under `also`
   in its TEAM.md. Anything else is a request to the owning team.
3. **Identity Integrity**: Identity is inherited: this constitution → company
   SOUL.md → primary role SOUL.md → TEAM.md soul override → owned repository
   AGENTS.md.
4. **Permission Boundaries**: Destructive or irreversible actions — on
   servers, data, DNS, money, or git history — need explicit operator
   confirmation in the session that performs them. An accepted request is not
   that confirmation.
5. **Commit Protocol**: A team commits in the repositories it owns when the
   operator has asked for commits in that session. Request files on the board
   may be committed by the team that wrote or answered them without further
   approval: {{yes | no}}.
6. **Task Continuity**: A team's canonical task state is
   `.crux/workspace/{team}/TODO.md` at the company root; the coordinator's is
   `.crux/workspace/TODO.md`. `NOTES.md` is never the source of truth.
7. **Sensitive Data**: Credentials, statements, and customer data stay in the
   owning repository and out of request files, memory, and the company
   repository. A request references them by path, never by content.
8. **Board Hygiene**: A request open or unanswered for more than {{7}} days
   is surfaced by the coordinator.
