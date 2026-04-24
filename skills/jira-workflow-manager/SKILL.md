---
name: jira-workflow-manager
description: >
  Manages Jira issues, searches, transitions, comments, sprint operations, and
  lightweight project coordination through an Atlassian MCP integration. Use
  when: the user asks to create a Jira ticket, search Jira issues, update an
  issue, move an issue through workflow, review sprint work, or turn team work
  into tracked Jira items.
license: MIT
compatibility: opencode
metadata:
  owner: team-operations-coach
  type: read-write
  approval: Yes — user approval required before write operations in Jira
---

# jira-workflow-manager

**Owner**: `team-operations-coach`
**Type**: `read-write`
**Approval**: `Yes — user approval required before write operations in Jira`

---

## What I Do

Uses an Atlassian MCP integration to search Jira, inspect issues, validate projects and fields,
and safely perform approved issue-management operations such as create, update, transition,
comment, and lightweight sprint coordination.

This skill is adapted for Crux so it fits the team-operations and coordination layer rather than
becoming a general-purpose always-on ticket bot.

---

## When to Use Me

- User asks to create or update a Jira issue
- User wants to search Jira issues or inspect issue details
- User wants to transition work through a Jira workflow
- Team coordination should be synced into Jira tickets
- Sprint or epic coordination needs a Jira-backed execution layer

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/team-operations-coach/MEMORY.md

Loads during execution (lazy):
  .crux/docs/team-operations-principles.md
  .crux/docs/weekly-team-reporting-format.md
  {operations-root}/weekly/
  {operations-root}/reports/

External requirement:
  Atlassian MCP integration must be configured and reachable.
  Expected tool namespace: mcp__atlassian__*

Expected environment or MCP-side config may include:
  JIRA_URL
  JIRA_EMAIL
  JIRA_API_TOKEN
  JIRA_PROJECTS_FILTER

Estimated token cost: ~700 tokens
Unloaded after: task completion
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `operation` | user | Yes — search / get / create / update / transition / comment / sprint-review |
| `project-key` | user / MEMORY.md | No for search, Yes for create in most cases |
| `issue-key` | user | No — required for get / update / transition / comment |
| `query` | user | No — used for search or issue creation details |
| `fields` | user | No |

---

## Supported Operations

Read-only by default:
- search issues with JQL
- get issue details
- list projects
- inspect fields
- inspect transitions
- review board or sprint state when supported by MCP

Write operations requiring approval:
- create issue
- update issue
- transition issue
- add comment
- link issues
- assign issue
- sprint or board mutations

---

## Steps

```
1. Identify requested Jira operation:
   search / get / create / update / transition / comment / sprint-review

2. Validate prerequisites:
   IF Atlassian MCP is unavailable
     → stop and report configuration requirement

3. For create or update:
   collect or confirm:
     project key
     issue type
     summary
     description or context
     priority if needed
     assignee if needed
     labels/components/custom fields if relevant

4. Validate Jira project and field assumptions before any write:
   use project listing and field search tools where needed

5. For read-only requests:
   run the minimum required Jira MCP queries
   summarize results in plain language

6. Before any write:
   present exact intended Jira action
   show target issue/project and important fields
   wait for explicit approval

7. On approval:
   execute the Jira write through MCP
   capture identifiers, changed status, and follow-up actions

8. Write a local coordination note when useful:
   {operations-root}/reports/YYYY-Www-jira-sync.md

9. Return:
   outcome
   affected issues
   blockers
   suggested next step

10. Skill complete — unload
```

---

## Output

**Writes to**: `{operations-root}/reports/YYYY-Www-jira-sync.md` when a saved coordination output is useful
**Format**: `markdown`

```markdown
# Jira Coordination Summary

## Request

## Jira Actions
- searched / created / updated / transitioned / commented

## Affected Issues
| Issue | Change | Status | Notes |
|---|---|---|---|

## Risks Or Blockers

## Suggested Next Step
```

---

## Approval Gate

```
Before any Jira write operation:

1. Present plan:
   "I am about to perform a Jira write operation."

2. Show:
   - operation type
   - project key or issue key
   - summary of fields that will change
   - workflow transition target if applicable

3. Wait for explicit confirmation.

4. On approval:
   execute through Atlassian MCP
   record outcome in a coordination note if useful

5. On rejection:
   stop and return a no-change summary
```

---

## Error Handling

| Condition | Action |
|---|---|
| Jira project key missing for create | ask for project key; never assume |
| MCP unavailable or auth invalid | stop and report configuration/auth blocker |
| Requested transition not valid | list available transitions instead of guessing |
| Custom field unclear | inspect field definitions before writing |
| Unexpected failure | Stop. Write error to bus. Notify user. |
