---
name: cost-efficiency-analyser
description: >
  Compares cost, operating effort, and expected value across solution options.
  Use when: the user asks cloud vs local, build vs buy, pilot vs full rollout,
  or whether a proposed solution is heavier than the business problem justifies.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# cost-efficiency-analyser

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Produces a practical trade-off analysis that balances cost, operational load, expected benefit,
and over-engineering risk.

---

## When to Use Me

- Cloud vs local or hybrid choice
- Build vs buy or tool selection
- A solution feels expensive or overbuilt
- Leadership needs a simple ROI-style recommendation

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/cost-efficiency-heuristics.md  (generate from agent assets first if missing)

Estimated token cost: ~350 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `options` | user | Yes |
| `cost-sensitivity` | MEMORY.md / user | No |
| `constraints` | user | No |

---

## Steps

```
1. List the realistic options being compared
2. Evaluate direct cost, operating burden, security exposure, and delivery speed
3. Highlight where complexity outweighs expected value
4. Recommend the most practical option
5. Provide one fallback if assumptions change
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Cost / Efficiency Trade-Off

| Option | Cost | Effort | Risk | Fit |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

## Recommendation
- ...

## Alternative
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Options are not comparable yet | state what data is missing |
| Cost numbers are weak | use directional language and mark assumptions |
| Unexpected failure | Stop. Write error to bus. Notify user. |
