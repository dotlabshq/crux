# TODO

> Canonical task state for this workspace scope.
> Lives in `.crux/workspace/TODO.md` for the coordinator or
> `.crux/workspace/{role}/TODO.md` for an agent.
> This file is the source of truth for task continuity and completion state.
>
> Do not use `NOTES.md` as the canonical task tracker.
> `NOTES.md` is supporting context only.

---

## Status Model

- `todo` — known but not started
- `in_progress` — actively being worked
- `waiting` — paused pending external input or dependency
- `blocked` — cannot proceed until a blocker is resolved
- `done` — acceptance criteria met
- `canceled` — intentionally stopped or superseded

---

## Task Records

## T-EXAMPLE-001
- title: Example task
- status: todo
- owner: coordinator
- created_by: coordinator
- created_at: {{DATE}}
- updated_at: {{DATE}}
- acceptance_criteria: one clear completion rule
- next_step: describe the immediate next action
- evidence_refs:
  - .crux/workspace/sessions/{ulid}/scratch.md

---

## Rules

1. Update the task before starting meaningful work.
2. Update the task again when status changes.
3. Mark `done` only when acceptance criteria are actually met.
4. Use `waiting` for expected pauses and `blocked` for unresolved obstacles.
5. If a task is superseded, mark it `canceled` and reference the replacement task.
