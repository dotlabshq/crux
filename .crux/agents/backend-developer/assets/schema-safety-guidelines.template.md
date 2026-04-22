# Schema Safety Guidelines

This reference supports backend work that touches persistence-sensitive paths.

## Treat As Sensitive

- migrations
- ORM models tied to production data
- tenant isolation logic
- auth and identity tables
- billing or ledger data

## Review Questions

- Does this change alter persisted shape or meaning?
- Does it affect backwards compatibility?
- Does it create rollout ordering concerns?
- Does it require data migration or operational review?

## Output Rule

If schema-sensitive risk exists, call it out explicitly before implementation or approval.
