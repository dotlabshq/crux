---
name: leadership-style-mapper
description: >
  Maps natural management answers into internal growth, support, and team maturity
  signals without asking the user to use abstract codes directly. Use when:
  onboarding or reporting needs plain-language leadership and maturity mapping.
license: MIT
compatibility: opencode
metadata:
  owner: team-operations-coach
  type: read-write
  approval: No
---

# leadership-style-mapper

**Owner**: `team-operations-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Converts natural answers about autonomy, leadership style, and team maturity into internal `G`, `S`, and `T` signals.

---

## When to Use Me

- Onboarding has collected management-style answers
- Team reviews need plain-language leadership interpretation
- The system needs consistent internal maturity signals

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/team-operations-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/situational-leadership-mapping.md   (generate from agent assets first if missing)

Estimated token cost: ~250 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `natural-autonomy-signal` | onboarding / user | Yes |
| `natural-leadership-signal` | onboarding / user | Yes |
| `natural-team-maturity-signal` | onboarding / user | Yes |

---

## Steps

```
1. Read the natural-language answers
2. Map them conservatively into plain-language conclusions first
3. Derive internal G/S/T signals for storage consistency
4. Store the plain-language explanation alongside the internal codes
5. Return the mapping summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
## Management Interpretation
- Teams currently show mixed autonomy and need moderate structure.
- Leadership style is closer to coaching than pure direction.
- Team maturity appears to be moving from early rhythm to a more stable cadence.

## Internal Signals
- Team maturity: T2
- Support style: S2
- Growth assumption: mixed, closer to G2-G3 depending on role
```

---

## Error Handling

| Condition | Action |
|---|---|
| Signals are too vague | Return a cautious mixed-state interpretation |
| Answers conflict strongly | Record assumptions clearly and suggest review |
| Unexpected failure | Stop. Write error to bus. Notify user. |
