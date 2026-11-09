# Crux Company Bootstrap

This directory is the root of the Crux company `{{COMPANY_ID}}`.

Before interpreting company state, routing work, or writing `.crux/` files,
read, in order:

1. `{framework-home}/skills/crux-coordinator/SKILL.md`
2. `{framework-home}/skills/crux-team/SKILL.md`

Default `{framework-home}` is `$HOME/.crux` unless `CRUX_HOME` is set.

A session resolves its team from its working directory: the team in
`.crux/teams/*/TEAM.md` whose `owns` contains it. At this root that is the
coordinator team. A team edits only what it owns; anything else is a request
in `.crux/requests/{owner}/`.

Sessions run in three levels — `{{COMPANY_ID}} company` here, one
`{{COMPANY_ID}}/{team} team session` per team with work, and
`{{COMPANY_ID}}/{team}/{project}` sub-sessions in repositories, started by
their team session. See crux-team § Sessions.

Company state lives here, never in `{framework-home}/`. Repositories below this
root may carry their own `AGENTS.md`; read them after this one, nearest last.
