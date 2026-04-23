# Onboarding: Backend Developer

> This file defines the onboarding sequence for the `backend-developer` agent.
> The goal is to establish backend context once, then let stack-specific behaviour
> live in skills rather than in separate permanent backend agents.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/backend-developer/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the Backend Developer agent.

This agent helps with:
- backend architecture understanding
- API and service implementation
- schema-sensitive review
- backend test writing
- backend documentation

I will inspect the repository first, then ask only the backend questions that
cannot be discovered automatically.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Detect likely backend language and manifest files
  2. Detect likely backend entry points, service directories, and test directories
  3. Check whether .crux/docs/ contains generated backend references
     If missing, note that they must be generated from this agent's assets during Step 4
  4. Check whether .crux/docs/backend.md exists
     If missing, note that codebase-scanner should be offered or run during Step 4

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3 if relevant
```

---

## Step 3 — User Questions

Ask one question at a time.

```
Question order:

1. "I detected this backend stack: {detected-language} with {detected-framework-or-runtime}.
    Is that correct?"
   default: yes
   stores-to: MEMORY.md → primary-language / framework

2. "What is the main backend entry point or service start command, if it is not obvious?"
   default: use detected entry point
   stores-to: MEMORY.md → backend-entrypoint / start-command

3. "Are there any backend directories I should treat as read-only or extra sensitive?
    Example: generated code, legacy services, migration folders."
   default: none
   stores-to: MEMORY.md → readonly-backend-paths

4. "Are there any API or schema areas where I should be especially careful?
    Example: public endpoints, billing, auth, tenant data."
   default: none
   stores-to: MEMORY.md → protected-backend-surfaces

5. "What is the preferred backend test command, if the repository uses a custom one?"
   default: detect from repository
   stores-to: MEMORY.md → backend-test-command
```

---

## Step 4 — Generate Docs

Run the appropriate skills to produce the initial backend references.

```
Required docs for this agent:
  .crux/docs/backend-development-principles.md  → generate from agents/backend-developer/assets/backend-development-principles.template.md if missing
  .crux/docs/api-contract-guidelines.md         → generate from agents/backend-developer/assets/api-contract-guidelines.template.md if missing
  .crux/docs/backend-testing-strategy.md        → generate from agents/backend-developer/assets/backend-testing-strategy.template.md if missing
  .crux/docs/schema-safety-guidelines.md        → generate from agents/backend-developer/assets/schema-safety-guidelines.template.md if missing
  .crux/docs/backend.md                         → skill: codebase-scanner if missing or if user wants a fresh architecture scan

If backend.md is missing:
  offer or run codebase-scanner
```

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for Backend Developer:

  - detected language and framework
  - detected or confirmed backend entry point
  - backend test command
  - read-only or sensitive backend paths
  - protected backend surfaces
  - generated backend reference docs

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/backend-developer/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → backend-developer / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: backend-developer
4. Notify user:
   "Backend Developer is ready.
    You can now use @backend-developer for backend implementation, review, tests, and documentation."
```

---

## Re-Onboarding

Re-run onboarding when:
- the backend stack changes materially
- the main backend entry point changes
- protected backend surfaces change
- the preferred test command changes

Re-onboarding should update durable preferences without overwriting backend notes unless requested.
