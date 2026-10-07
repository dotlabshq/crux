---
id: {{TEAM_ID}}
roles:
  - {{PRIMARY_ROLE_ID}}
skills: []
owns:
  - {{PATH_RELATIVE_TO_COMPANY_ROOT}}
also: []
---

# {{TEAM_ID}}

{{What this team is for, in a paragraph: the things it owns, who consumes
them, and what it never does.}}

## Soul override

<!-- Optional. Inherits .crux/SOUL.md, then the primary role's SOUL.md,
     exactly as an agent's Soul Override does. Delete if unused. -->

tone: {{…}}
additional-rules:
  - {{…}}

<!--
HOW TO USE THIS TEMPLATE

FILE LOCATION: {company-root}/.crux/teams/{{TEAM_ID}}/TEAM.md
Inbox:         {company-root}/.crux/requests/{{TEAM_ID}}/
Live state:    {company-root}/.crux/workspace/{{TEAM_ID}}/

id:      Lowercase slug, unique within the company. Qualified id is
         {company}/{{TEAM_ID}}. Must match the folder name.
roles:   One or more role ids from {framework-home}/agents/. The first is
         primary: its AGENT.md and SOUL.md are loaded at boot. Others are
         loaded when their domain is triggered.
skills:  Extra skill names added to the roles' skill tables.
owns:    Paths relative to the company root (../repo for a repository kept
         beside the company repository), or absolute. Exclusive: no two teams
         in a company own the same path. The coordinator team owns "." (the
         company root); a deeper owned path carves itself out of a shallower
         one, and the longest match decides.
also:    Paths this team may edit but does not own (shared surfaces such as a
         root README row or a justfile). Not exclusive.

A team edits only what it owns or lists under `also`. Anything else is a
request to the owning team. Reading is unrestricted.

Protocol: {framework-home}/skills/crux-team/SKILL.md
-->
