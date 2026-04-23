# Onboarding: Platform Engineer

> This file defines the onboarding sequence for the `platform-engineer` agent.
> The goal is to establish environment, pipeline, deploy, and observability context
> once, then let tool-specific behaviour live in skills instead of separate permanent agents.

---

## Prerequisites

Before onboarding begins, verify:

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/platform-engineer/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Greet the user and explain what this agent does.

```
You are setting up the Platform Engineer agent.

This agent helps with:
- environment review
- CI/CD and release pipeline work
- deployment configuration review
- observability checks
- runtime incident summaries

I will inspect the repository first, then ask only the platform questions that
cannot be discovered automatically.
```

---

## Step 2 — Environment Discovery

```
Run the following checks silently:
  1. Detect likely CI/CD files, environment config files, deploy config paths, and observability config
  2. Detect likely container, release, or deployment entry points
  3. Check whether .crux/docs/ contains generated platform references
     If missing, note that they must be generated from this agent's assets during Step 4
  4. Check whether .crux/docs/platform.md exists
     If missing, note that platform references should be generated during Step 4

For each check:
  IF successful   → record result in .crux/workspace/current/scratch.md
  IF failed       → note as "missing" and surface in Step 3 if relevant
```

---

## Step 3 — User Questions

Ask one question at a time.

```
Question order:

1. "I detected these platform signals: {detected-ci}, {detected-deploy}, {detected-env-pattern}.
    Is that roughly correct?"
   default: yes
   stores-to: MEMORY.md → primary-ci-system / deploy-pattern

2. "Which environments should I treat as the main ones?
    Example: local, staging, production."
   default: local, staging, production
   stores-to: MEMORY.md → primary-environments

3. "Are there any platform or config directories I should treat as read-only or extra sensitive?
    Example: production env files, deployment manifests, release config."
   default: none
   stores-to: MEMORY.md → readonly-platform-paths

4. "Are there any rollout or runtime surfaces I should handle carefully?
    Example: production deploy workflow, worker scaling, alert config, on-call dashboards."
   default: none
   stores-to: MEMORY.md → protected-platform-surfaces

5. "What is the preferred command or workflow for validating platform changes, if there is a custom one?"
   default: detect from repository
   stores-to: MEMORY.md → platform-validation-command
```

---

## Step 4 — Generate Docs

Run the appropriate skills to produce the initial platform references.

```
Required docs for this agent:
  .crux/docs/platform-principles.md           → generate from agents/platform-engineer/assets/platform-principles.template.md if missing
  .crux/docs/environment-guidelines.md        → generate from agents/platform-engineer/assets/environment-guidelines.template.md if missing
  .crux/docs/deployment-safety-guidelines.md  → generate from agents/platform-engineer/assets/deployment-safety-guidelines.template.md if missing
  .crux/docs/observability-guidelines.md      → generate from agents/platform-engineer/assets/observability-guidelines.template.md if missing
  .crux/docs/platform.md                      → generate from discovery and onboarding answers if missing

If platform.md is missing:
  create a concise platform summary from detected files and confirmed answers
```

---

## Step 5 — Review & Confirm

Present a summary of what was discovered and configured.

```
Onboarding summary for Platform Engineer:

  - detected CI/CD and deploy pattern
  - primary environments
  - detected or confirmed platform validation command
  - read-only or sensitive platform paths
  - protected platform surfaces
  - generated platform reference docs

Does this look correct?
  → Yes: finalise onboarding
  → No:  return to the relevant step
```

---

## Step 6 — Finalise

```
1. Write collected durable facts to .crux/workspace/platform-engineer/MEMORY.md
2. Update .crux/workspace/MANIFEST.md:
     add or update agent row → platform-engineer / pending-onboard → onboarded
3. Write event to .crux/bus/broadcast.jsonl:
     type: agent.onboarded
     from: platform-engineer
4. Notify user:
   "Platform Engineer is ready.
    You can now use @platform-engineer for environments, CI/CD, deployment review, observability, and runtime summaries."
```

---

## Re-Onboarding

Re-run onboarding when:
- the CI/CD or deploy pattern changes materially
- main environments change
- protected platform surfaces change
- the preferred validation command changes

Re-onboarding should update durable preferences without overwriting platform notes unless requested.
