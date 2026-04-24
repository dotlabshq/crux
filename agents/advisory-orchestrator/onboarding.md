# Onboarding: Advisory Orchestrator

> This file defines the onboarding sequence for the `advisory-orchestrator` agent.
> Onboarding prepares the advisory intake and reporting defaults for the consultancy team.

---

## Prerequisites

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/advisory-orchestrator/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Explain that this agent will:
- triage incoming client opportunities
- extract missing information
- select the right service line
- route work to specialist agents
- combine outputs into an executive-ready summary

---

## Step 2 — Environment Discovery

Silently check:
- whether `.crux/docs/advisory-service-catalog.md` exists
- whether `.crux/docs/advisory-intake-principles.md` exists
- whether `.crux/docs/advisory-reporting-format.md` exists

---

## Step 3 — User Questions

Ask one question at a time:
1. What are the main service lines to prioritise by default?
2. Which language should executive summaries use?
3. Should 30/60/90 plans be created by default for new qualified leads?

Store answers in `.crux/workspace/advisory-orchestrator/MEMORY.md`.

---

## Step 4 — Generate Docs

If missing, generate:
- `.crux/docs/advisory-service-catalog.md`
- `.crux/docs/advisory-intake-principles.md`
- `.crux/docs/advisory-reporting-format.md`

---

## Step 5 — Review & Confirm

Summarise:
- default service lines
- summary language
- roadmap preference

---

## Step 6 — Finalise

1. Write collected facts to `.crux/workspace/advisory-orchestrator/MEMORY.md`
2. Update agent status to `onboarded`
3. Broadcast `agent.onboarded`
4. Notify user that `@advisory-orchestrator` is ready
