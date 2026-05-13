---
name: developer-execution-discipline
description: >
  Enforces a disciplined implementation posture before coding or broad refactors:
  surface assumptions, narrow scope, prefer the simplest complete fix, define
  verification targets, and avoid speculative cleanup. Use when: a developer
  agent is about to implement, refactor, review, or change non-trivial code
  and there is meaningful ambiguity, risk, or temptation to over-engineer.
license: MIT
compatibility: opencode
metadata:
  owner: backend-developer
  type: read-only
  approval: No
---

# developer-execution-discipline

**Owner**: `backend-developer`
**Type**: `read-only`
**Approval**: `No`

---

## What I Do

Provide a shared execution discipline for developer agents so they do not jump
from vague intent to broad edits. This skill forces explicit assumptions,
smallest-sufficient scope, and concrete verification before non-trivial work.

---

## When to Use Me

- The user request is technically plausible but still ambiguous in meaning or scope
- A refactor, bug fix, or platform change could sprawl into unrelated cleanup
- A developer agent is about to choose between a simple fix and a more abstract redesign
- A non-trivial code change needs a clear verification target before editing

---

## Context Requirements

```
Requires already loaded:
  {framework-home}/agents/{role}/AGENT.md
  .crux/workspace/{role}/TODO.md

Loads during execution (lazy):
  task-specific docs or code paths only after scope is narrowed

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `user-request` | user | Yes |
| `candidate-scope` | local inspection | No |
| `affected-paths` | local inspection | No |

---

## Steps

```
1. Restate the task as a concrete change goal.

2. Surface material assumptions.
   IF an assumption changes implementation shape or risk
     → say it explicitly before editing.

3. Narrow the scope.
   Define the smallest set of files or behaviours that must change.
   Exclude adjacent cleanup unless the requested fix requires it.

4. Choose the simplest complete solution.
   Prefer the least abstract design that fully solves the task.
   Do not add indirection, configurability, or new layers without a concrete need.

5. Define verification before editing.
   State what will prove the change is correct:
   tests, behaviour, contract, output, or inspection target.

6. Implement only after steps 1-5 are clear.

7. On completion, summarise:
   - assumptions used
   - what changed
   - how it was verified

8. Skill complete — unload
```

---

## Output

**Writes to**: `none directly`
**Format**: `execution discipline applied to implementation`

```
- concrete goal
- explicit assumptions
- smallest sufficient scope
- simplest complete solution
- verification target
```

---

## Error Handling

| Condition | Action |
|---|---|
| Scope remains ambiguous | Ask the narrowest clarifying question or state the safest assumption |
| Simple fix and broad redesign are both possible | Prefer the simple fix and explain why the redesign is not yet justified |
| Verification is unclear | Define at least one concrete validation target before editing |
| Unexpected failure | Stop. Explain the blocker and preserve narrowed scope. |
