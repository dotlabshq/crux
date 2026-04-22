# Onboarding: Team Operations Coach

> This file defines the onboarding sequence for the `team-operations-coach` agent.
> The goal is to set up a markdown-first operating rhythm for teams without forcing
> users into abstract management theory language.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/team-operations-coach/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the Team Operations Coach agent.

This agent helps you:
- define teams, members, and ownership
- create weekly team plans and weekly summaries
- track blockers and dependencies
- prepare short management and leadership reports
- keep everything markdown-first under an operations/ structure

I will ask a short series of questions about your teams, weekly rhythm,
and preferred management style.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Check whether the chosen operations root already exists
  2. Check whether any team, people, weekly, or reports markdown files already exist under that root
  3. Check whether the chosen operations root already contains user-maintained templates
  4. Check whether .crux/docs/ contains generated team operations references
     If missing, note that they must be generated from this agent's assets during Step 4

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3 if relevant
```

---

## Step 3 — User Questions

Ask one question at a time. Keep the language natural and practical.

```
Question order:

1. "Where should your team operations structure live?
    Default: operations/
    You can also choose a custom path."
   default: operations/
   stores-to: MEMORY.md → operations-root

2. "Which teams do you want to track right now?
    Example: red, blue, compliance"
   default: none
   stores-to: MEMORY.md → tracked-teams

3. "What is each team's main responsibility, and who leads each one?"
   default: unknown
   stores-to: operations/teams/{team}.md → purpose + lead

4. "Do you want to track individual team members as well, or only teams?"
   default: teams-and-members
   stores-to: MEMORY.md → people-tracking-mode

5. "If you want member tracking, who is in each team right now?"
   default: unknown
   stores-to: operations/people/{person}.md → team + role

6. "How do you want to manage this structure?
    Options in plain language:
    - simple and lightweight
    - lean and visibility-focused
    - coaching and development-focused
    - hybrid"
   default: hybrid
   stores-to: MEMORY.md → management-mode

7. "Describe your teams in a few sentences: how independently do they work,
    what do team leads usually do (direct, coach, support, delegate?),
    and are they still forming or already running a steady rhythm?"
   default: mixed — describe freely
   stores-to:
     MEMORY.md → natural-autonomy-signal     (extracted by leadership-style-mapper)
     MEMORY.md → natural-leadership-signal   (extracted by leadership-style-mapper)
     MEMORY.md → natural-team-maturity-signal (extracted by leadership-style-mapper)
   note: leadership-style-mapper runs after onboarding to derive G/S/T signals
         from this single natural-language answer

8. "Should weekly reporting be more control-oriented, more development-oriented, or balanced?"
   default: balanced
   stores-to: MEMORY.md → reporting-intent

9. "When should weekly plans usually be written?"
   default: start-of-week
   stores-to: MEMORY.md → weekly-plan-cadence

10. "When should weekly summaries usually be written?"
    default: end-of-week
    stores-to: MEMORY.md → weekly-review-cadence

11. "Do you want blockers and cross-team dependencies reported separately?"
    default: yes
    stores-to: MEMORY.md → separate-blocker-report

12. "Do you want a short organisation summary every week for leadership?"
    default: yes
    stores-to: MEMORY.md → weekly-org-summary

13. "Should I suggest weekly updates when the current week is missing?"
    default: yes
    stores-to: MEMORY.md → auto-suggest-weekly-plan
```

Do not ask the user directly to choose `G1-G4`, `S1-S4`, or `T1-T4`.
Instead, use `leadership-style-mapper` after the natural-language questions are complete.

---

## Step 4 — Generate Docs

Run the appropriate skills to produce the initial operations references, templates, and starter files.

```
Required docs for this agent:
  .crux/docs/team-operations-principles.md                 → generate from agents/team-operations-coach/assets/team-operations-principles.template.md if missing
  .crux/docs/situational-leadership-mapping.md             → generate from agents/team-operations-coach/assets/situational-leadership-mapping.template.md if missing
  .crux/docs/weekly-team-reporting-format.md               → generate from agents/team-operations-coach/assets/weekly-team-reporting-format.template.md if missing
  {operations-root}/templates/team-card.md                 → generate or preserve existing
  {operations-root}/templates/person-card.md               → generate or preserve existing
  {operations-root}/templates/weekly-team-plan.md          → generate or preserve existing
  {operations-root}/templates/weekly-team-review.md        → generate or preserve existing
  {operations-root}/templates/org-weekly-summary.md        → generate or preserve existing

On first onboarding, create these folders under {operations-root}/:
  teams
  people
  weekly
  reports
  templates

Then:
  1. run leadership-style-mapper on the single natural-language answer from question 7
     → extracts natural-autonomy-signal, natural-leadership-signal, natural-team-maturity-signal
     → stores plain-language interpretation + G/S/T codes in MEMORY.md
  2. generate starter team cards for each named team
  3. if member tracking is enabled, generate person cards for named members
  4. if weekly-org-summary == yes, generate the org summary template
```

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for Team Operations Coach:

  - operations root
  - tracked teams
  - tracking mode: teams only or teams + members
  - management mode
  - weekly plan cadence
  - weekly review cadence
  - blocker / dependency reporting preference
  - weekly org summary preference
  - internal mapped signals for team maturity and leadership style

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

Explain the mapped signals in plain language first.
Only mention the internal `G/S/T` labels if helpful as an additional note.

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/team-operations-coach/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → team-operations-coach / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: team-operations-coach
4. Notify user:
   "Team Operations Coach is ready.
    You can now manage teams, weekly plans, weekly summaries, and leadership reporting under your operations structure."
```

---

## Re-Onboarding

Re-run onboarding when:
- team structure changes materially
- weekly cadence changes
- the operations root changes
- the user wants a different management mode or reporting style
- quarterly team health review is due (recommended every ~12 weeks to re-verify natural-autonomy-signal,
  natural-leadership-signal, and natural-team-maturity-signal — these change as teams grow)

Re-onboarding should update durable preferences without overwriting user-maintained operations notes unless requested.
