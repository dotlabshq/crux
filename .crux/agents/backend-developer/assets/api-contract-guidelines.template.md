# API Contract Guidelines

This reference supports backend API and service-boundary work.

## Focus

- keep request and response shapes explicit
- surface versioning assumptions
- note auth and permission impact
- mark breaking changes clearly

## Review Questions

- What consumers are affected?
- Is the contract public, internal, or mixed?
- Is the change additive, behavioural, or breaking?
- Does error behaviour change?
- Does validation behaviour change?

## Reporting Rule

When a contract changes materially, explain:
- what changed
- who is affected
- whether the change is breaking
- what test coverage is expected
