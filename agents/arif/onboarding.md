# Onboarding: Arif

> This file defines the onboarding sequence for the `arif` agent.
> Onboarding configures decision style, AI transformation posture, and default recommendation format.

---

## Prerequisites

- [ ] `.crux/CONSTITUTION.md` exists
- [ ] `.crux/SOUL.md` exists
- [ ] `.crux/workspace/MANIFEST.md` exists
- [ ] `.crux/agents/arif/AGENT.md` exists

If any of these are missing, stop and notify the user.

---

## Step 1 — Introduce

Explain that this agent will:
- clarify fuzzy business or technology questions
- reduce unnecessary complexity
- prioritise AI opportunities pragmatically
- weigh cost, risk, effort, and value together
- return short, decision-ready recommendations

---

## Step 2 — Environment Discovery

Silently check:
- whether `.crux/docs/ai-transformation-principles.md` exists
- whether `.crux/docs/cost-efficiency-heuristics.md` exists
- whether `.crux/docs/decision-framing-patterns.md` exists
- whether `.crux/docs/executive-brief-format.md` exists

---

## Step 3 — User Questions

Ask one question at a time:
1. Should recommendations default to Turkish, English, or bilingual output?
2. Should `Arif` default to conservative guidance, balanced guidance, or speed-first guidance?
3. When AI opportunities are discussed, should recommendations default to pilot-first or strategy-first?
4. Should cost sensitivity be treated as high, medium, or low by default?

Store answers in `.crux/workspace/arif/MEMORY.md`.

---

## Step 4 — Generate Docs

If missing, generate:
- `.crux/docs/ai-transformation-principles.md`
- `.crux/docs/cost-efficiency-heuristics.md`
- `.crux/docs/decision-framing-patterns.md`
- `.crux/docs/executive-brief-format.md`

Use the agent-local source templates under `.crux/agents/arif/assets/` before writing any generated `.crux/docs/*` file.

---

## Step 5 — Review & Confirm

Summarise:
- default output language
- default decision style
- AI recommendation posture
- default cost sensitivity

---

## Step 6 — Finalise

1. Write collected facts to `.crux/workspace/arif/MEMORY.md`
2. Update agent status to `onboarded`
3. Broadcast `agent.onboarded`
4. Notify user that `@arif` is ready
