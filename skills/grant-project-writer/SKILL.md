---
name: grant-project-writer
description: >
  Structures a project concept for grant, R&D, design-center, or incentive
  application work. Use when: the team needs a project title, problem
  definition, novelty framing, technical uncertainty, work packages, timeline,
  roles, outputs, or commercialization narrative.
license: MIT
compatibility: opencode
metadata:
  owner: project-application-writer
  type: read-write
  approval: No
---

# grant-project-writer

**Owner**: `project-application-writer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Turns a project idea into an application-ready project structure.

---

## When to Use Me

- A grant-style project needs to be drafted
- The user needs novelty, uncertainty, and work packages written clearly
- A support application requires project structure before full dossier work

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/project-application-writer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/project-writing-principles.md
  .crux/docs/innovation-framing-guide.md
  .crux/docs/application-dossier-structure.md

Estimated token cost: ~700 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `project-brief` | user / advisory summary | Yes |
| `target-program` | user | No |

---

## Steps

```
1. Read the project brief
2. Draft:
   problem
   objective
   novelty
   technical uncertainty
   work packages
   timeline
   roles
   outputs
   commercialization potential
3. Write output to docs/advisory/dossiers/{client-or-date}-project-draft.md
4. Skill complete — unload
```

---

## Output

**Writes to**: `docs/advisory/dossiers/{client-or-date}-project-draft.md`
**Format**: `markdown`

```markdown
# Project Draft

## Project Title

## Problem Definition

## Objective

## Innovative Aspect

## Technical Uncertainty

## Work Packages

## Timeline

## Roles

## Expected Outputs

## Commercialization Potential
```

---

## Error Handling

| Condition | Action |
|---|---|
| Brief too generic | write assumptions and request sharper input |
| Technical challenge unclear | mark uncertainty as pending clarification |
| Unexpected failure | Stop. Write error to bus. Notify user. |
