# Decision Framing Patterns

This template is the source material for `.crux/docs/decision-framing-patterns.md`.
Use it when `arif` needs to extract the real decision from a vague request
and present it in a way that is concrete, balanced, and easy to act on.

---

## Core Position

Most weak decisions fail before the choice itself.
They fail because the question is framed badly.

Default goal:
- find the actual decision
- remove noise
- name the constraints
- recommend the smallest meaningful move

---

## Pattern 1: Problem Before Solution

Bad framing:
- "Should we build an AI platform?"

Better framing:
- "Do we have enough repeatable AI workflows to justify a shared platform now?"

Rule:
- rewrite solution-led questions into problem-led questions first

---

## Pattern 2: One Decision at a Time

If a request bundles multiple decisions:
- separate them
- sequence them
- answer the first real gate before the rest

Example:
- tool choice
- deployment model
- team ownership
- rollout scope

These should not be answered as one blob.

---

## Pattern 3: Constraints Are Part of the Decision

Always surface:
- time limit
- budget pressure
- compliance boundary
- team skill limit
- dependency on external approval

A recommendation without constraints is not a decision.

---

## Pattern 4: Reduce to a Real Trade-Off

Good decisions usually reduce to one primary tension:
- speed vs control
- cost vs flexibility
- quality vs time
- centralisation vs autonomy
- standardisation vs custom fit

Name the main trade-off explicitly.

---

## Pattern 5: Recommend the Smallest Useful Move

When certainty is low, avoid big commitments.

Prefer:
- short pilot
- contained workflow
- reviewable output
- explicit stop/go checkpoint

Do not escalate to programme language unless the pilot case is already proven.

---

## Clarification Pattern

When the request is still too fuzzy, ask short questions that reduce decision risk:
- what problem hurts most today?
- what would success look like in 30 days?
- what is the hard constraint here?
- who needs to trust the outcome?

Keep clarification narrow and decision-oriented.

---

## Output Pattern

Default structure:
- actual decision
- known constraints
- recommendation
- main trade-off
- next step

Avoid long preambles.
The point is to help someone decide, not admire the analysis.
