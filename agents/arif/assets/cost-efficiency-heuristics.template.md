# Cost Efficiency Heuristics

This template is the source material for `.crux/docs/cost-efficiency-heuristics.md`.
Use it when `arif` compares cloud vs local, build vs buy, pilot vs rollout,
or any option set where cost, effort, and operational burden matter.

---

## Core Position

The cheapest option on paper is often not the cheapest option to operate.

Always evaluate:
- direct spend
- operating overhead
- delivery speed
- security/compliance friction
- change burden on the team

---

## Practical Heuristics

### Prefer simple managed services when:
- the workflow is not a core differentiator
- the team is small
- uptime/SRE maturity is limited
- the speed of learning matters more than unit-cost optimisation

### Prefer local or self-hosted approaches when:
- data sensitivity is material
- predictable workloads justify steady infrastructure
- external API cost becomes structurally expensive
- model or workflow control is strategically important

### Prefer buy before build when:
- the capability is common
- integration cost is acceptable
- vendor risk is manageable
- the team would otherwise spend months recreating commodity behaviour

### Prefer build when:
- the workflow is core to the business
- internal nuance matters more than generic tooling
- available products impose unacceptable process or pricing constraints

---

## Complexity Tax

Every added system has hidden cost:
- integration maintenance
- onboarding time
- approval friction
- operational troubleshooting
- reporting ambiguity

If a new layer does not materially improve value, remove it.

---

## Cloud vs Local Framing

Ask:
1. Is the workload bursty or steady?
2. Is data sensitivity moderate or high?
3. Is speed more important than optimisation right now?
4. Can the current team operate the chosen model safely?
5. Does the usage pattern justify infrastructure ownership?

Do not answer cloud vs local with ideology.
Answer it with:
- workload pattern
- team capability
- compliance exposure
- financial shape

---

## ROI Language

Use directional business language unless strong numbers exist:
- lower operating burden
- faster time to value
- reduced review cost
- lower vendor dependency
- improved cost predictability

Avoid false precision when the inputs are weak.

---

## Default Recommendation Pattern

1. Name the most practical option
2. Explain why it fits current maturity
3. Call out the main trade-off
4. Offer one fallback if assumptions change

Short form:
- best now
- why
- trade-off
- when to revisit
