---
id: {{COMPANY_ID}}
name: {{COMPANY_NAME}}
coordinator: coordinator
task_tool: none
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
task_tool:   The skill the company chose for task and approval management,
             or `none`. Chosen at Company Onboarding; the value is a skill
             name under {framework-home}/skills/ whose metadata says
             `category: task-tool` (today: clave-workflow-manager). Every
             coordinator and team session loads that skill at boot and no
             other task tool. A missing field means `none`.
created:     Date the company was initialised.

Protocol: {framework-home}/skills/crux-team/SKILL.md
-->
