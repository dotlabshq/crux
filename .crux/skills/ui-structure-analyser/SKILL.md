---
name: ui-structure-analyser
description: >
  Analyses frontend structure, routes, components, and major UI surfaces. Use
  when: the user asks how the frontend is organised, wants a UI architecture
  scan, or needs frontend structure identified before a change.
license: MIT
compatibility: opencode
metadata:
  owner: frontend-developer
  type: read-write
  approval: No
---

# ui-structure-analyser

**Owner**: `frontend-developer`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Maps frontend structure and writes a concise frontend architecture note.

---

## When to Use Me

- `.crux/docs/frontend.md` is missing
- User asks how the UI is organised
- A change needs route/component context first

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/frontend-developer/MEMORY.md

Loads during execution (lazy):
  .crux/docs/component-structure-guidelines.md  (generate from agent assets first if missing)
  .crux/docs/state-flow-guidelines.md           (generate from agent assets first if missing)

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `project-root` | current working directory | Yes |

---

## Steps

```
1. Detect likely frontend entry, route, component, and test areas
2. Summarise structure, major UI surfaces, and state boundaries
3. Write .crux/docs/frontend.md
4. Optionally write .crux/summaries/frontend.md when practical
5. Return a concise frontend structure summary
6. Skill complete — unload
```

---

## Output

**Writes to**: `.crux/docs/frontend.md`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Frontend area not detected clearly | Return best-effort candidate paths and uncertainty |
| `.crux/docs/` not writable | Fallback to workspace output and notify user |
| Unexpected failure | Stop. Write error to bus. Notify user. |
