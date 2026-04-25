# MySQL Query Review Guidelines

This template is the source material for `.crux/docs/mysql-query-review-guidelines.md`.
Use it when `mysql-admin` reviews slow queries or tuning direction.

---

## Core Position

Query tuning should respond to measured cost, not intuition alone.

Review with this order:
- confirm the symptom
- review slow query or explain evidence
- inspect schema and index context
- identify likely bottleneck class
- recommend the smallest useful tuning move

---

## Common Bottleneck Classes

- missing index
- table scan on large relation
- poor join path
- temporary table or sort pressure
- too-broad result set

---

## Recommendation Style

- keep advice practical
- separate query rewrite from index work
- do not recommend broad config changes without instance evidence
