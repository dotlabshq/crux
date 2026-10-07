---
id: {{ULID}}
from: {{COMPANY_ID}}/{{REQUESTER_TEAM}}
to: {{COMPANY_ID}}/{{OWNER_TEAM}}
type: task
status: open
parent_id:
context_refs:
  - {{path/to/waiting/file:line}}
opened: {{DATE}}
closed:
---

# {{One line: what is needed}}

## Why

{{What the requester is building and what it is blocked on. Link the file
that is waiting.}}

## What

{{The surface as the requester would consume it — endpoint, field, command,
document. The owner may change the shape; say what must hold.}}

## Done when

{{A sentence the owner can test against.}}

## Owner's notes

<!-- Filled by the owner only: what was done, commit id, version, or the
     reason for declining and the alternative. -->

<!--
HOW TO USE THIS TEMPLATE

FILE LOCATION: {company-root}/.crux/requests/{{OWNER_TEAM}}/{{DATE}}-{{slug}}.md
               Date first so an inbox lists oldest first; slug says what is
               wanted (expose-jti-on-session, bump-client-for-exchange).

id:           ULID. Sortable, unique, no coordination required.
from / to:    Qualified team ids, {company}/{team}. A `to` in another company
              resolves through {framework-home}/companies.toml.
type:         task | approval-request | event | error
              (bus/protocol.md message types; approval-request goes to the
              coordinator team's folder)
status:       open → accepted → done, or open → declined
parent_id:    id of the request this answers or follows, if any.
context_refs: files the requester is waiting in, or that explain the need.
opened:       set by the requester.
closed:       set by the owner together with status done or declined.

Writers:
  requester  writes the file, deletes it after reading done/declined.
  owner      changes status, closed and Owner's notes only.

A request that needs two teams is two files.

Protocol: {framework-home}/skills/crux-team/SKILL.md
-->
