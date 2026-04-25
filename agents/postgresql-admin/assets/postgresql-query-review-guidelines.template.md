# PostgreSQL Query Review Guidelines

This template is the source material for `.crux/docs/postgresql-query-review-guidelines.md`.
Use it when `postgresql-admin` reviews slow queries or tuning direction.

---

## Core Position

Query tuning should solve measured bottlenecks, not guess at them.

Review with this order:
- confirm workload symptom
- identify heavy queries
- understand table and index context
- explain likely bottleneck class
- recommend the smallest useful next tuning move

---

## Common Bottleneck Classes

- missing or weak index
- bad row estimates / stale statistics
- sequential scan on large relation
- nested loop misuse on large result sets
- unnecessary sort or aggregation pressure

---

## Recommendation Style

- prefer plain-language tuning guidance
- do not recommend schema churn casually
- distinguish "needs explain" from "clear bottleneck already visible"
