# Onboarding: Frontend Developer

> This file defines the onboarding sequence for the `frontend-developer` agent.
> The goal is to establish frontend context once, then let stack-specific behaviour
> live in skills rather than in separate permanent frontend agents.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/frontend-developer/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the Frontend Developer agent.

This agent helps with:
- frontend architecture understanding
- component and UI implementation
- state-flow review
- frontend test writing
- frontend documentation

I will inspect the repository first, then ask only the frontend questions that
cannot be discovered automatically.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Detect likely frontend language, framework, and manifest files
  2. Detect likely frontend entry points, route areas, component folders, and test folders
  3. Check whether .crux/docs/ contains generated frontend references
     If missing, note that they must be generated from this agent's assets during Step 4
  4. Check whether .crux/docs/frontend.md exists
     If missing, note that ui-structure-analyser should be offered or run during Step 4

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3 if relevant
```

---

## Step 3 — User Questions

Ask one question at a time.

```
Question order:

1. "I detected this frontend stack: {detected-language} with {detected-framework-or-runtime}.
    Is that correct?"
   default: yes
   stores-to: MEMORY.md → frontend-language / framework

2. "What is the main frontend entry point, route root, or app shell, if it is not obvious?"
   default: use detected entry point
   stores-to: MEMORY.md → frontend-entrypoint

3. "Are there any frontend directories I should treat as read-only or extra sensitive?
    Example: generated components, design tokens, shared UI library."
   default: none
   stores-to: MEMORY.md → readonly-frontend-paths

4. "Are there any high-risk UI surfaces I should handle carefully?
    Example: auth flows, checkout, dashboard navigation, shared forms."
   default: none
   stores-to: MEMORY.md → protected-frontend-surfaces

5. "What is the preferred frontend test command, if the repository uses a custom one?"
   default: detect from repository
   stores-to: MEMORY.md → frontend-test-command
```

---

## Step 4 — Generate Docs

Run the appropriate skills to produce the initial frontend references.

```
Required docs for this agent:
  .crux/docs/frontend-development-principles.md → generate from agents/frontend-developer/assets/frontend-development-principles.template.md if missing
  .crux/docs/component-structure-guidelines.md  → generate from agents/frontend-developer/assets/component-structure-guidelines.template.md if missing
  .crux/docs/frontend-testing-strategy.md       → generate from agents/frontend-developer/assets/frontend-testing-strategy.template.md if missing
  .crux/docs/state-flow-guidelines.md           → generate from agents/frontend-developer/assets/state-flow-guidelines.template.md if missing
  .crux/docs/frontend.md                        → skill: ui-structure-analyser if missing or if user wants a fresh frontend scan

If frontend.md is missing:
  offer or run ui-structure-analyser
```

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for Frontend Developer:

  - detected language and framework
  - detected or confirmed frontend entry point
  - frontend test command
  - read-only or sensitive frontend paths
  - protected frontend surfaces
  - generated frontend reference docs

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/frontend-developer/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → frontend-developer / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: frontend-developer
4. Notify user:
   "Frontend Developer is ready.
    You can now use @frontend-developer for UI implementation, review, tests, and frontend documentation."
```

---

## Re-Onboarding

Re-run onboarding when:
- the frontend stack changes materially
- the main frontend entry point changes
- protected frontend surfaces change
- the preferred test command changes

Re-onboarding should update durable preferences without overwriting frontend notes unless requested.
