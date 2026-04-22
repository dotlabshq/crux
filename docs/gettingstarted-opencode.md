# Getting Started With OpenCode

This guide is for first-time users who want to try Crux in OpenCode without needing
deep technical knowledge.

The goal is simple:
- open the project
- use one real agent
- complete onboarding once
- turn a messy task list into a useful daily plan

This guide uses one beginner-friendly scenario:
- `Personal Task Triage` with `@personal-productivity-coach`

It is the fastest way to understand how Crux feels in practice.

---

## Before You Start

Make sure:
- Crux is installed in your project
- you opened the project in OpenCode
- the assistant can see the files in this workspace

You do not need to understand the full `.crux/` structure yet.
This guide is about getting value quickly.

![OpenCode workspace ready](images/gettingstarted-opencode-01-workspace-ready.png)

Suggested screenshot:
- OpenCode open in the Crux project
- project files visible in the sidebar
- `.crux/` visible so the user sees this is a workspace-based setup

---

## Scenario: Personal Task Triage

### What You Will Do

You will use `@personal-productivity-coach`.

The agent will:
- ask a short onboarding sequence the first time you use it
- set up a markdown planning structure under your chosen notes root
- turn a messy list of tasks, reminders, and half-finished thoughts into:
  - a clean triage note
  - clear priorities
  - blockers or missing information
  - a realistic daily plan

This is a good first demo because:
- it is easy to understand
- it does not require expert knowledge
- it shows both onboarding and real output generation

---

## Step 1: Start The Agent

Open a normal conversation in OpenCode and call the agent directly:

```text
@personal-productivity-coach
I want to get started with personal task triage.
```

The first run should trigger onboarding automatically.

![Start the personal productivity agent](images/gettingstarted-opencode-02-start-agent.png)

Suggested screenshot:
- the first message using `@personal-productivity-coach`
- the agent responding and beginning onboarding

---

## Step 2: Complete Onboarding

The onboarding is intentionally short. It will ask things like:
- where your planning notes should live
- whether you want a framework such as `PARA`
- whether work and personal tasks should stay together or separate
- your preferred output style
- your preferred planning language

A typical onboarding flow looks like this:

```text
@personal-productivity-coach
I want to get started with personal task triage.

Agent:
Where should your planning and note structure live?
Default: notes/

You:
notes/

Agent:
Do you want to use a productivity framework for organising notes and tasks?
Suggested default: PARA.

You:
PARA
```

Keep going until onboarding is complete.

![Onboarding questions](images/gettingstarted-opencode-03-onboarding.png)

Suggested screenshot:
- the onboarding questions in progress
- one or two answered questions visible
- enough of the chat to show this is not a technical setup flow

---

## Step 3: Paste A Messy Task List

Once onboarding is done, give the agent a real messy list.

Use your own list, or paste something like this:

```text
I need to reply to the landlord
book dentist appointment
finish comparing HR software options
ask Ayse about next week's client meeting
review bank charges
buy birthday gift for my sister
prepare slides for Friday
figure out why the team shared drive is messy
call mom
renew domain payment maybe this week
```

Then ask:

```text
Help me triage this task list.
Group related items, identify the top priorities for today, list blockers or missing information,
and create a daily plan I can actually follow.

Tasks:
[paste your messy list here]
```

![Paste a messy task list](images/gettingstarted-opencode-04-messy-task-list.png)

Suggested screenshot:
- the user prompt with the messy list
- enough visible content to show the input is intentionally unstructured

---

## Step 4: Let The Agent Run Its Skills

Behind the scenes, `@personal-productivity-coach` will typically use:
- `task-triage`
- `today-plan-writer`
- and, if needed, `follow-up-questioner`

You do not need to call these skills manually.
The point of the demo is to experience the agent as a usable assistant, not as a technical workflow.

What should happen:
- the task list is grouped into meaningful buckets
- unclear items are called out
- active work is separated from waiting or blocked work
- a daily plan is written in markdown

---

## Step 5: Review The Output

A useful result usually includes:
- grouped tasks
- a short list of top priorities
- explicit unknowns
- waiting items
- a short “next actions” section

You should also expect the agent to save markdown output into your chosen notes root.
For example:
- `notes/00 Inbox/...`
- `notes/Daily Notes/...`
- `notes/Templates/...`

![Task triage result](images/gettingstarted-opencode-05-triage-result.png)

Suggested screenshot:
- the assistant response showing grouped priorities
- visible sections such as `Top Priorities`, `Waiting`, or `Needs Clarification`

![Generated markdown notes](images/gettingstarted-opencode-06-generated-notes.png)

Suggested screenshot:
- file tree showing the generated notes structure under the chosen notes root
- one daily note or triage note visible in the sidebar

---

## What Good Output Looks Like

A strong first result usually has:
- no long rambling explanation
- a realistic number of top priorities
- separate `waiting` and `blocked` items
- a short markdown note the user can keep

If the result is too broad, continue with:

```text
Make this shorter and more actionable.
Keep only:
- top priorities for today
- waiting items
- things that need clarification
```

If you want the note to feel more reusable, continue with:

```text
Turn this into a clean markdown daily note and save it in my notes structure.
```

---

## Why This Is A Good First Use Case

It teaches the core Crux interaction model:
- call a real agent
- complete a lightweight onboarding
- give messy input
- let the agent apply the right skills
- keep the result as reusable markdown

You do not need:
- coding knowledge
- infrastructure access
- external integrations
- a complicated workflow

---

## Tips For First-Time Users

- Start with messy, real input. Do not over-prepare it.
- Let onboarding finish before judging the experience.
- Ask for one clear transformation at a time.
- If the answer is too general, ask for a shorter structured result.
- Ask for Markdown if you want something reusable.

Good follow-up phrases:
- `make this shorter`
- `turn this into a checklist`
- `separate urgent from non-urgent`
- `show assumptions`
- `write this as a note I can save`

---

## What You Learn From This Demo

Even without expert workflows, this example shows the core Crux/OpenCode experience:
- turning chaos into structure
- using a real agent instead of a generic prompt
- generating reusable markdown output
- keeping the result in a note system that can also work well with Obsidian later

After this, the next guide can introduce another simple everyday workflow in a separate document.
