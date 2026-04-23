---
name: {{skill-name}}
description: >
  {{What this skill does and when to use it. Include "Use when:" scenarios.
  Agents read this to decide whether to load — be specific.}}
license: MIT
compatibility: opencode
metadata:
  owner: {{OWNER_AGENT_ROLE_ID}}
  type: {{read-only | read-write}}
  approval: {{No | Yes | Yes — role}}
---

<!--
FRONTMATTER GUIDE (opencode SKILL.md spec)

name          required — lowercase alphanumeric, hyphens allowed, no leading/trailing hyphens
              must match the folder name containing this SKILL.md
              regex: ^[a-z0-9]+(-[a-z0-9]+)*$

description   required — 1–1024 characters
              write enough for an agent to decide whether to load this skill
              always include "Use when:" scenarios

license       optional
compatibility optional — opencode | claude | agents | all
metadata      optional — string-to-string map, any keys allowed

Crux convention for metadata:
  owner     role-id of the agent that owns this skill
  type      read-only (no file writes) | read-write (may write files)
  approval  No | Yes | Yes — {role} (human approval before writes)
-->

# {{skill-name}}

**Owner**: `{{OWNER_AGENT_ROLE_ID}}`
**Type**: `{{read-only | read-write}}`
**Approval**: `{{No | Yes | Yes — role}}`

---

## What I Do

{{Brief description of what this skill accomplishes}}

---

## When to Use Me

- {{USE_CASE_1}}
- {{USE_CASE_2}}
- {{USE_CASE_3}}

---

## Context Requirements

```
Requires already loaded:
  .crux/agents/{{OWNER}}/MEMORY.md    (for {{specific fields}})

Loads during execution (lazy):
  {{FILE_IF_NEEDED}}

Estimated token cost: ~{{N}} tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `{{INPUT_1}}` | {{user / MEMORY.md / bus message / live discovery}} | {{Yes / No}} |
| `{{INPUT_2}}` | {{user / MEMORY.md / bus message / live discovery}} | {{Yes / No}} |

---

## Steps

```
1. {{STEP_1}}

2. {{STEP_2}}

3. {{STEP_3}}
   IF {{condition}}
     → {{action}}
   ELSE
     → {{alternative}}

4. Write output to {{OUTPUT_PATH}}

5. Skill complete — unload
```

---

## Output

**Writes to**: `{{OUTPUT_PATH}}`
**Format**: `{{markdown | json | yaml}}`

```
{{OUTPUT_STRUCTURE}}
```

---

## Approval Gate

<!-- Remove this section if approval: No -->

```
Before any write operation:

1. Present plan: "I am about to {{action}} on {{target}}.
   Impact: {{impact}}."
2. Show exact command or file change.
3. Wait for explicit confirmation.
4. On approval  → execute, log to .crux/bus/{{OWNER}}/
5. On rejection → stop, note in workspace/current/scratch.md
```

---

## Error Handling

| Condition | Action |
|---|---|
| `{{ERROR_1}}` | {{ACTION_1}} |
| `{{ERROR_2}}` | {{ACTION_2}} |
| Unexpected failure | Stop. Write error to bus. Notify user. |

---

## Example Output

```
{{REALISTIC_EXAMPLE_OF_WHAT_THIS_SKILL_PRODUCES}}
```