---
name: cross-team-summary-writer
description: >
  Writes a short organisation-level summary across multiple teams, highlighting
  progress, blockers, dependencies, and leadership attention items. Use when:
  the user wants a weekly management report, cross-team summary, or leadership brief.
license: MIT
compatibility: opencode
metadata:
  owner: team-operations-coach
  type: read-write
  approval: No
---

# cross-team-summary-writer

**Owner**: `team-operations-coach`
**Type**: `read-write`
**Approval**: `No`

---

## What I Do

Builds a short cross-team summary from team weekly notes without drowning the user in detail.

---

## When to Use Me

- User wants an org weekly summary
- Leadership needs a short operations brief
- Cross-team visibility is needed

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/team-operations-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/team-operations-principles.md      (generate from agent assets first if missing)
  .crux/docs/weekly-team-reporting-format.md    (generate from agent assets first if missing)
  {operations-root}/templates/org-weekly-summary.md
  {operations-root}/weekly/
  {operations-root}/reports/

Estimated token cost: ~450 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `week-id` | user / system date | No — default: current week |
| `team-list` | MEMORY.md / user | No — default: tracked teams |

---

## Steps

```
1. Load the relevant weekly team notes for the requested teams
2. Build a short executive summary
3. Add team-by-team snapshots
4. Surface major blockers, cross-team dependencies, and leadership attention items
5. Save the weekly org summary
6. Return a concise summary preview
7. Skill complete — unload
```

---

## Output

**Writes to**: `{operations-root}/reports/YYYY-Www-org-summary.md`
**Format**: `markdown`

---

## Error Handling

| Condition | Action |
|---|---|
| Some team notes are missing | Summarise available teams and mark missing coverage explicitly |
| Weekly data looks stale | Surface stale status in the report |
| Unexpected failure | Stop. Write error to bus. Notify user. |
