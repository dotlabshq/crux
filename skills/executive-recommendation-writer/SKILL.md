---
name: executive-recommendation-writer
description: >
  Produces a short management-ready recommendation that explains the situation,
  the preferred path, the main trade-off, and the next step. Use when:
  leadership wants a concise answer, a consultant-style memo is needed, or a
  longer analysis should be compressed into one clear decision note.
license: MIT
compatibility: opencode
metadata:
  owner: arif
  type: read-write
  approval: No
---

# executive-recommendation-writer

**Owner**: `arif`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Compresses analysis into a short recommendation memo suitable for leadership review or client discussion.

---

## When to Use Me

- A user says "give me the recommendation"
- Leadership needs a brief instead of a workshop output
- Several observations must become one clear decision note

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/arif/MEMORY.md

Loads during execution (lazy):
  .crux/docs/executive-brief-format.md  (generate from agent assets first if missing)

Estimated token cost: ~250 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `analysis` | user / prior skills | Yes |
| `audience` | user | No — default: leadership |
| `tone` | MEMORY.md / user | No |

---

## Steps

```
1. Extract the key situation in plain language
2. State the preferred recommendation first
3. Highlight the main trade-off and the main risk
4. Give one practical next step
5. Keep the memo short enough to read in one sitting
6. Skill complete — unload
```

---

## Output

**Writes to**: `no file required by default`
**Format**: `markdown`

```markdown
# Executive Recommendation

## Situation
- ...

## Recommendation
- ...

## Trade-Off
- ...

## Next Step
- ...
```

---

## Error Handling

| Condition | Action |
|---|---|
| Analysis is too weak | state missing assumptions instead of pretending confidence |
| The recommendation is not decision-ready | reduce to one clear path and one alternative only |
| Unexpected failure | Stop. Write error to bus. Notify user. |
