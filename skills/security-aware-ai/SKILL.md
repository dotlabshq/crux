---
name: security-aware-ai
description: >
  Evaluates AI decisions through privacy, data exposure, control, and operational
  risk. Use when: the user asks whether AI should run in cloud or local, whether
  data can leave the company boundary, what the KVKK/privacy implications are,
  or how to weigh AI value against security and compliance risk.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# security-aware-ai

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Frames AI decisions with security, privacy, and control in mind so recommendations are not
useful on paper but risky in operation.

---

## When to Use Me

- Local vs cloud AI decision
- Sensitive data may leave the company
- KVKK/privacy exposure needs to be considered
- The user needs risk-aware AI guidance

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/ai-transformation-principles.md   (generate from agent assets first if missing)
  .crux/docs/cost-efficiency-heuristics.md     (generate from agent assets first if missing)

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `use-case` | user | Yes |
| `data-types` | user | No |
| `deployment-options` | user | No |
| `constraints` | user | No |

---

## Steps

```
1. Identify what data is involved and where it would flow
2. Evaluate exposure, control, retention, and review risk
3. Compare local, cloud, or hybrid options in plain language
4. State the main security/compliance trade-off
5. Recommend the safest practical path, not the safest theoretical path
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Security-Aware AI Decision

## Use Case
- ...

## Main Risk
- ...

## Deployment Trade-Off
- ...

## Recommendation
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Data sensitivity is unclear | ask what data classes are involved before recommending deployment |
| Compliance detail exceeds this skill | escalate to compliance-governance-lead |
| Unexpected failure | Stop. Write error to bus. Notify user. |
