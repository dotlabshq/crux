# Onboarding: Personal Productivity Coach

> This file defines the onboarding sequence for the `personal-productivity-coach` agent.
> Onboarding should stay short, practical, and easy for a first-time user.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/personal-productivity-coach/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the Personal Productivity Coach agent.

This agent helps with:
- task triage
- daily planning
- weekly review notes
- markdown notes that work well in an Obsidian-style knowledge base

I will ask a few short questions so the note structure and planning style fit the way you work.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Check whether the chosen notes root already exists
  2. Check whether any markdown planning notes already exist under the chosen notes root
  3. Check whether the chosen notes root already contains user-maintained templates
  4. Check whether .crux/docs/ contains generated personal productivity references
     If missing, note that they must be generated from this agent's assets during Step 4

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3 if relevant
```

---

## Step 3 — User Questions

Ask one question at a time.

```
Question order:

1. "Where should your planning and note structure live?
    Default: notes/
    You can also choose a custom path."
   default: notes/
   stores-to: MEMORY.md → notes-root

2. "Do you want to use a productivity framework for organising notes and tasks?
    Suggested default: PARA.
    You can also choose simple-folder mode or name another framework."
   default: PARA
   stores-to: MEMORY.md → preferred-framework

3. "Should work and personal tasks be shown together or separately?"
   default: together
   stores-to: MEMORY.md → separate-work-and-personal

4. "What should the default output style be?
    Options: checklist / short-note / daily-plan"
   default: daily-plan
   stores-to: MEMORY.md → preferred-output-format

5. "How should priorities be grouped by default?
    Options: today-this-week-later / urgent-normal-low"
   default: today-this-week-later
   stores-to: MEMORY.md → priority-buckets

6. "When an item is unclear, should I ask follow-up questions first or make a best-effort guess?"
   default: ask-follow-up
   stores-to: MEMORY.md → clarification-style

7. "Do you want a daily note suggestion when there is no note for today?"
   default: yes
   stores-to: MEMORY.md → auto-suggest-daily-note

8. "What language should planning notes default to?"
   default: user's current language
   stores-to: MEMORY.md → preferred-language
```

---

## Step 4 — Generate Docs

Run the appropriate skills to produce the initial planning support docs and templates.

```
Required docs for this agent:
  .crux/docs/task-triage-principles.md           → generate from agents/personal-productivity-coach/assets/task-triage-principles.template.md if missing
  .crux/docs/personal-planning-formats.md        → generate from agents/personal-productivity-coach/assets/personal-planning-formats.template.md if missing
  .crux/docs/obsidian-productivity-structure.md  → generate from agents/personal-productivity-coach/assets/obsidian-productivity-structure.template.md if missing
  {notes-root}/Templates/Daily Note.md           → generate or preserve existing
  {notes-root}/Templates/Weekly Review.md        → generate or preserve existing
  {notes-root}/00 Inbox/README.md                → generate if missing

On first onboarding, create these folders under {notes-root}/:
  00 Inbox
  01 Projects
  02 Areas
  03 Resources
  04 Archives
  Daily Notes
  Weekly Notes
  Templates
```

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for Personal Productivity Coach:

  - notes root
  - framework preference
  - work/personal split
  - output format
  - priority grouping
  - clarification style
  - daily note suggestion setting
  - planning language

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/personal-productivity-coach/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → personal-productivity-coach / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: personal-productivity-coach
4. Notify user:
   "Personal Productivity Coach is ready.
    You can now ask for task triage, a daily plan, or a weekly review note."
```

---

## Re-Onboarding

Re-run onboarding when:
- the preferred framework changes
- the root note structure changes materially
- the user wants different output styles or planning language

Re-onboarding should update durable preferences without overwriting user notes unless requested.
