---
id: {{COMPANY_ID}}
name: {{COMPANY_NAME}}
coordinator: coordinator
created: {{DATE}}
---
{{One sentence on what the company is.}}

<!--
HOW TO USE THIS TEMPLATE

FILE LOCATION: {company-root}/.crux/COMPANY.md
               Its presence marks {company-root} as a Crux company.

id:          Lowercase slug, unique on this machine. Must match the key in
             {framework-home}/companies.toml. Qualifies every team id:
             {{COMPANY_ID}}/{team}.
name:        Display name.
coordinator: Id of the team that routes, keeps the board and aggregates
             approvals. Its TEAM.md lives at .crux/teams/{coordinator}/ and
             owns the company root.
created:     Date the company was initialised.

Protocol: {framework-home}/skills/crux-team/SKILL.md
-->
