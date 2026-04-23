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

Load strategy (context budget):
  → prefer {operations-root}/summaries/YYYY-Www-{team-name}.md if doc-summariser has run
  → load full weekly note only when summary is missing
  → hard cap: ~300 tokens per team when loading full notes
  → if total team count > 5: process teams in two passes (batch A then B), combine in final output
  → never load all team weekly notes simultaneously when team count > 8

Estimated token cost: ~450 tokens base + ~300 tokens per team (full) or ~100 per team (summary)
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
1. Resolve team list from MEMORY.md → tracked-teams or user input
2. For each team:
   IF summaries/YYYY-Www-{team-name}.md exists → load summary (~100 tokens)
   ELSE load {operations-root}/weekly/YYYY-Www/{team-name}.md capped at ~300 tokens
   IF team count > 5 → process in two batches; combine outputs before step 3
3. Build a short executive summary across all teams
4. Add team-by-team snapshots (key result + main blocker per team, max 3 lines each)
5. Surface major blockers, cross-team dependencies, and leadership attention items
6. Save the weekly org summary
7. Return a concise summary preview
8. Skill complete — unload
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
| Team count > 8 and context is tight | Warn user, offer a subset summary or per-team pass |
| Unexpected failure | Stop. Write error to bus. Notify user. |
