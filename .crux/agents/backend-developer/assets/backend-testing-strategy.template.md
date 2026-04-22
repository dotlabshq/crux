# Backend Testing Strategy

This reference supports backend validation and test planning.

## Purpose

Keep backend test guidance short and practical.

## Default Expectations

- add tests for changed behaviour when practical
- if not adding tests, explain why
- prefer focused tests over broad fragile coverage
- call out missing coverage in risky paths

## Useful Test Layers

- unit tests for isolated business logic
- integration tests for persistence or service boundaries
- contract tests for public API behaviour where relevant

## Review Rule

For non-trivial backend edits, state:
- what should be tested
- what was tested
- what remains risky
