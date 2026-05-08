---
name: risk-acceptance-decision-note
description: >
  Writes a formal, management-ready note for residual risk, delayed
  remediation, or exception handling that identifies the risk, business impact,
  compensating controls, owner, and sign-off need. Use when: remediation is
  delayed, a control gap remains, or formal risk acceptance wording is needed.
license: MIT
compatibility: opencode
metadata:
  owner: ciso-advisor
  type: read-write
  approval: No
---

# risk-acceptance-decision-note

**Owner**: `ciso-advisor`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Prepare formal wording for residual risk and sign-off without pretending that security can approve business risk alone.

---

## When to Use Me

- Remediation is delayed
- A control gap cannot be closed immediately
- A formal exception or sign-off note is needed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/ciso-advisor/MEMORY.md

Loads during execution (lazy):
  .crux/docs/risk-framing-patterns.md
  .crux/docs/compliance-reporting-guide.md

Estimated token cost: ~300 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `risk-context` | user / prior analysis | Yes |
| `owner-context` | user / MEMORY.md | No |

---

## Steps

```
1. Describe the unresolved risk and why it remains open
2. State impact, compensating controls, and exposure period
3. Identify decision owner and sign-off path
4. Make the residual risk explicit
5. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Sign-off owner is unclear | State the missing owner explicitly |
| Residual risk is understated | Reframe in practical business terms |
| Unexpected failure | Stop. Write error to bus. Notify user. |
